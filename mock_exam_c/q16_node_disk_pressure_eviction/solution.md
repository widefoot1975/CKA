# q16 — Pods evicted under node disk pressure · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`worker02` 의 파드들이 사라지고 있다. 여러 개가 `Evicted` 상태이고, 새 파드는 노드가 선택되지
않은 채 `Pending` 에 머문다. 다른 노드는 정상이다.

1. 이를 설명하는 노드 컨디션과 kubelet이 붙인 메시지를 보인다.
2. `worker02` 에 적용된 kubelet 축출 임계값과 어떤 파일시스템 시그널이 임계를 넘었는지 보고한다.
3. 디스크를 무엇이 소비하는지 찾는다. 컨테이너 이미지, 컨테이너 로그, 기타 데이터를 구분한다.
4. 컨디션이 해제되도록 공간을 회수한다. 사용하지 않는 이미지는 `/var/lib/containerd` 아래 파일을
   손으로 지우지 말고 컨테이너 런타임을 통해 제거한다.
5. 노드가 다시 파드를 받는지 확인하고 `Evicted` 파드 오브젝트를 정리한다.
6. 축출된 파드와 OOMKilled된 컨테이너의 차이를 한 줄로 적는다.

## 모범 풀이

**1) 노드 컨디션** — 위에서 아래로 내려갑니다.

```bash
kubectl get nodes
# worker02  Ready  (Ready 는 유지된다 — DiskPressure 만으로는 NotReady 가 아니다)

kubectl describe node worker02
# Conditions:
#   Type            Status  Reason                  Message
#   DiskPressure    True    KubeletHasDiskPressure  kubelet has disk pressure
# Taints: node.kubernetes.io/disk-pressure:NoSchedule
```

`DiskPressure=True` 가 되면 kubelet이 노드에 `node.kubernetes.io/disk-pressure:NoSchedule`
테인트를 자동으로 붙입니다. 그래서 스케줄러가 새 파드를 배치하지 않고 `Pending` 에 머무는 것입니다.
`describe pod <pending>` 의 Events에 `0/3 nodes are available: 1 node(s) had untolerated taint
{node.kubernetes.io/disk-pressure: }` 가 나옵니다.

```bash
kubectl get pods -A --field-selector=status.phase=Failed
kubectl describe pod <evicted-pod> | grep -A3 Status
# Status: Failed / Reason: Evicted
# Message: The node was low on resource: ephemeral-storage. ...
```

**2) 임계값** (worker02, root)

```bash
grep -A10 evictionHard /var/lib/kubelet/config.yaml
# evictionHard:
#   imagefs.available: 15%
#   memory.available: 100Mi
#   nodefs.available: 10%
#   nodefs.inodesFree: 5%

ps aux | grep kubelet | tr ' ' '\n' | grep eviction     # 플래그로 준 경우
df -h /var/lib/kubelet /var/lib/containerd /
df -i /                                                 # inode 소진도 같은 증상을 낸다
```

시그널이 네 가지라는 점이 중요합니다. `nodefs` 는 kubelet이 쓰는 파일시스템(emptyDir, 로그),
`imagefs` 는 런타임이 이미지와 컨테이너 쓰기 레이어를 두는 파일시스템입니다. 둘이 같은 디스크인
경우가 많지만 분리되어 있으면 어느 쪽이 찼는지에 따라 조치가 달라집니다. 그리고 용량이 넉넉한데도
`nodefs.inodesFree` 로 축출되는 경우가 있어 `df -h` 만 보면 원인을 놓칩니다.

**3) 소비원 찾기**

```bash
du -sh /var/lib/containerd /var/log/pods /var/lib/kubelet/pods 2>/dev/null
du -sh /var/log/pods/* | sort -h | tail -10
crictl images                                   # 이미지 목록
crictl imagefsinfo
journalctl --disk-usage
```

| 소비원 | 확인 | 조치 |
|---|---|---|
| 사용하지 않는 이미지 | `crictl images` 가 많고 `du /var/lib/containerd` 가 큼 | `crictl rmi --prune` |
| 컨테이너 로그 누적 | `du -sh /var/log/pods/*` 에 큰 항목 | 해당 파드 재생성, kubelet `containerLogMaxSize` 설정 |
| 종료된 컨테이너 잔여물 | `crictl ps -a` 에 Exited 다수 | `crictl rm $(crictl ps -a -q --state exited)` |
| journald 로그 | `journalctl --disk-usage` 가 GB 단위 | `journalctl --vacuum-size=200M` |
| emptyDir에 쓰는 파드 | `du -sh /var/lib/kubelet/pods/*` | 해당 파드의 `sizeLimit` 설정 또는 삭제 |

**4) 회수**

```bash
crictl rmi --prune                              # 어떤 컨테이너도 참조하지 않는 이미지 삭제
crictl rm $(crictl ps -a -q --state exited)     # 종료된 컨테이너 정리
journalctl --vacuum-size=200M
df -h /
```

`/var/lib/containerd` 를 직접 `rm` 하면 containerd의 메타데이터 DB와 실제 레이어가 어긋나
이후 모든 이미지 pull이 깨집니다. 반드시 `crictl rmi` 를 통해야 합니다.

kubelet은 자체 GC도 하지만 `imageGCHighThresholdPercent` (기본 85) 에 도달해야 동작하고,
하드 축출 임계(15% 여유)가 더 먼저 걸리는 설정이면 GC가 돌기 전에 축출이 시작됩니다.

공간이 확보되면 kubelet이 다음 평가 주기(기본 10초)에 컨디션을 내리지만,
`evictionPressureTransitionPeriod` (기본 5분) 동안 플래핑 방지를 위해 유지되므로 즉시 사라지지
않습니다. 5분을 기다리거나 `systemctl restart kubelet` 으로 앞당깁니다.

**5) 정리**

```bash
kubectl delete pods -A --field-selector=status.phase=Failed
```

`Evicted` 파드는 Failed 상태의 껍데기 오브젝트로 남습니다. 컨테이너는 이미 사라졌고 디스크를
차지하지 않으므로 급하지는 않지만, `get pods` 출력을 어지럽히고 ReplicaSet 파드라면 이미
대체 파드가 다른 노드에 떠 있습니다.

**6) 차이**: 축출(Eviction)은 **kubelet이 노드 자원 부족을 판단해 파드 전체를 종료**하고
파드가 `Failed/Evicted` 로 남는 것이며, OOMKilled는 **커널이 컨테이너의 cgroup 메모리 limit 초과를
보고 그 컨테이너 하나만 SIGKILL** 해서 파드는 유지되고 재시작 카운트가 오르는 것입니다.

## 검증

```bash
kubectl describe node worker02 | grep -A6 Conditions
# DiskPressure  False  KubeletHasNoDiskPressure

kubectl describe node worker02 | grep -i taint      # disk-pressure 테인트 없음
df -h /                                             # Use% 가 임계 아래

kubectl run probe --image=nginx --overrides='{"spec":{"nodeName":"worker02"}}'
kubectl get pod probe -o wide                       # Running, NODE=worker02

kubectl get pods -A --field-selector=status.phase=Failed    # No resources found
crictl images | wc -l                               # 줄어들었다
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `DiskPressure=True` → kubelet이 `NoSchedule` 테인트를 자동 부착 → 새 파드가 Pending.
- **헷갈리는 지점**: `nodefs.available` 과 `imagefs.available` 은 서로 다른 시그널이고 조치도 다릅니다.
  또 `df -h` 는 정상인데 축출되는 경우가 있는데, 이때는 거의 항상 `df -i` 의 inode 소진
  (`nodefs.inodesFree`)입니다. 그리고 공간을 비워도 컨디션이 바로 내려가지 않는 것은 버그가 아니라
  `evictionPressureTransitionPeriod` (기본 5분) 때문입니다 — 여기서 조급하게 다른 것을 건드리면 상황을 악화시킵니다.

## 참고 문서

- 검색어: `node-pressure eviction`
- https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/
- https://kubernetes.io/docs/reference/node/node-status/#condition

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
