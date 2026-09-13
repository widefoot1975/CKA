# q15 — Pods stuck in ContainerCreating after a CNI failure · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`worker01` 에 스케줄된 모든 파드가 `ContainerCreating` 에서 멈춘다. `worker02` 의 파드는 정상적으로
시작한다. `worker01` 은 `Ready` 로 보고된다. deployment `apps/web` 는 replica가 4이고
`worker02` 에 있는 것만 IP를 가진다.

1. 실패를 설명하는 파드 이벤트를 `/opt/q15/event.txt` 에 적는다.
2. `worker01` 에서 런타임과 CNI 상태를 확인한다. CNI 설정 디렉터리 경로와 거기서 발견한 것을
   `/opt/q15/cni.txt` 에 적는다.
3. 원인을 찾아 `/opt/q15/cause.txt` 에 적는다.
4. 모든 `apps/web` 파드가 pod IP를 가진 `Running` 이 되도록 고친다.
5. 실패한 시도가 남긴 sandbox를 정리한다.

## 모범 풀이

`ContainerCreating` 은 kubelet이 **sandbox 를 만들다가** 막힌 상태입니다. 이미지 pull 문제라면
`ImagePullBackOff` 가 되고, 프로세스 문제라면 `CrashLoopBackOff` 가 됩니다.
`ContainerCreating` 이 오래 유지되는 원인은 거의 CNI, 볼륨 마운트, 또는 secret/configmap 누락
셋 중 하나입니다.

**1단계 — 이벤트가 어느 쪽인지 즉시 갈라줍니다.**

```bash
kubectl -n apps describe pod -l app=web | grep -A10 Events
```

```
Warning  FailedCreatePodSandBox  kubelet
  Failed to create pod sandbox: rpc error: code = Unknown desc = failed to setup network
  for sandbox "9b1c...": plugin type="bridge" failed (add): failed to find plugin "bridge"
  in path [/opt/cni/bin]
```

이 문구가 나오면 볼륨도 secret도 아니고 **네트워크 플러그인**입니다. 볼륨 문제라면
`MountVolume.SetUp failed`, secret 누락이면 `secret "x" not found` 가 같은 자리에 나옵니다.

**2단계 — 노드로 내려가 두 디렉터리를 봅니다.** CNI는 설정과 바이너리, 두 조각이 필요합니다.

```bash
ls -l /etc/cni/net.d/          # 설정 (*.conf / *.conflist)
ls -l /opt/cni/bin/            # 플러그인 바이너리
journalctl -u kubelet --since '-10min' | grep -i cni
systemctl is-active containerd
```

**3단계 — 원인 분류.** 증상 문구가 원인을 좁혀줍니다.

| 이벤트 / 로그 문구 | 원인 | 조치 |
|---|---|---|
| `cni plugin not initialized` / 노드가 `NotReady` with `NetworkPluginNotReady` | `/etc/cni/net.d` 가 비어 있음 | CNI DaemonSet 재배포, 설정 복원 |
| `failed to find plugin "X" in path [/opt/cni/bin]` | 플러그인 바이너리 누락 | 바이너리 복원, CNI DaemonSet 재시작 |
| `failed to allocate for range 0: no IP addresses available in range` | 노드 IPAM 고갈 | `/var/lib/cni/networks/<net>/` 의 고아 임대 정리 |
| `error getting ClusterInformation: connection is unauthorized` | CNI 컨트롤러 RBAC/토큰 문제 | CNI 파드 로그 확인 |
| CNI 파드가 그 노드에만 없음 | taint 미허용 / nodeSelector | toleration 또는 라벨 수정 |
| 파드 CIDR 불일치 | CNI 설정의 subnet ≠ 노드 `podCIDR` | 설정 정합성 수정 |

여기서는 CNI DaemonSet 파드가 `worker01` 에 떠 있지 않아 설정과 바이너리를 깔아주지 못한
경우입니다. 먼저 그 파드를 확인합니다.

```bash
kubectl -n kube-system get pods -o wide | grep -iE 'calico|flannel|cilium|weave'
kubectl -n kube-system describe pod <cni-pod-on-worker01>
kubectl -n kube-system logs <cni-pod-on-worker01> -c install-cni
```

**노드가 `Ready` 인데 CNI가 깨져 있는 상태가 이 문제의 핵심입니다.** 한 번이라도 CNI 설정이
정상이었던 노드는 kubelet이 `Ready` 를 유지하므로 `kubectl get nodes` 만 보면 아무 이상이
없어 보입니다. 즉 노드 상태가 초록색이라는 것이 CNI가 지금 동작한다는 증거는 아닙니다.

**4단계 — 복구.** CNI DaemonSet 파드를 그 노드에서 다시 띄우면 init container가
`/etc/cni/net.d` 와 `/opt/cni/bin` 을 다시 채웁니다.

```bash
kubectl -n kube-system delete pod <cni-pod-on-worker01>
# 또는 전체 재적용
kubectl -n kube-system rollout restart ds <cni-daemonset>

# 노드에서 채워졌는지 확인
ls -l /etc/cni/net.d/ /opt/cni/bin/
systemctl restart kubelet        # 설정이 늦게 반영될 때만
```

**5단계 — 남은 sandbox 정리.** 실패한 sandbox는 `NotReady` 로 남아 자리를 차지합니다.

```bash
crictl pods -a | grep NotReady
crictl rmp --all --force        # 중단된 sandbox 제거 (kubelet 이 다시 만든다)
kubectl -n apps delete pod -l app=web    # 파드를 새로 생성시킨다
```

## 검증

```bash
kubectl -n apps get pods -l app=web -o wide
# 4개 모두 Running, IP 열이 채워져 있고 worker01/worker02 에 분산
kubectl -n kube-system get ds | grep -iE 'calico|flannel|cilium'   # DESIRED == READY

POD=$(kubectl -n apps get pod -l app=web -o name | head -1)
kubectl -n apps exec $POD -- wget -qO- --timeout=3 http://web.apps/ | head -2
```

노드에서:

```bash
ls /etc/cni/net.d/                  # 10-calico.conflist 등이 존재
crictl pods -a | grep -c NotReady   # 0
journalctl -u kubelet --since '-2min' | grep -ci FailedCreatePodSandBox   # 0
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `ContainerCreating` 에서 멈추면 `describe pod` 의 `FailedCreatePodSandBox` 메시지를 읽는다. 그 한 줄이 CNI / 볼륨 / secret 중 어느 쪽인지 바로 알려준다.
- **헷갈리는 지점**: 노드가 `Ready` 라도 CNI가 고장 나 있을 수 있습니다 — `NetworkPluginNotReady` 로 NotReady가 되는 것은 CNI 설정이 처음부터 없던 경우뿐입니다. 그리고 `/etc/cni/net.d`(설정)와 `/opt/cni/bin`(플러그인 바이너리)는 별개라서 한쪽만 있으면 실패 메시지가 서로 다릅니다. `crictl rm` 은 컨테이너, `crictl rmp` 는 sandbox입니다.

## 참고 문서

- 검색어: `debug pods`
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/
- https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
