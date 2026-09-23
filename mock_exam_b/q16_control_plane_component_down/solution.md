# q16 — A control plane component is not running · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

새로 만든 파드가 스케줄링 이벤트 없이 계속 `Pending` 이다. 기존 파드는 계속 돌고 `kubectl` 도
정상 동작한다.

1. 어느 컨트롤 플레인 컴포넌트가 실패하고 있는지 찾아 이름을 `/opt/q16/component.txt` 에 적는다.
2. 그 컴포넌트의 파드가 `kubectl get pods -n kube-system` 에 보이지 않으므로, `cp01` 에서 컨테이너
   런타임과 kubelet journal로 원인을 찾는다. 결정적인 로그 한 줄을 `/opt/q16/log.txt` 에 적는다.
3. 컴포넌트를 복구한다. `/etc/kubernetes/pki` 아래의 것은 삭제하지 않는다.
4. 새 파드가 스케줄되고 컴포넌트가 `Running`, `1/1` 인지 확인한다.
5. 이 컴포넌트의 매니페스트가 어디에 있고 왜 `kubectl delete pod` 로 재시작하는 것이 아닌지
   `/opt/q16/why.txt` 에 적는다.

## 모범 풀이

**1단계 — 증상이 범인을 지목합니다.** `kubectl` 이 동작하므로 API server와 etcd는 살아 있습니다.
"파드가 Pending인데 이벤트조차 없다"는 것은 **아무도 그 파드를 심사하지 않았다**는 뜻이므로
kube-scheduler입니다. 스케줄러가 살아 있는데 배치를 못 하는 경우라면
`0/3 nodes are available: insufficient cpu` 같은 `FailedScheduling` 이벤트가 남습니다.
이벤트가 **아예 없는 것**과 거절 이벤트가 있는 것을 구분하는 것이 핵심입니다.

```bash
kubectl -n default describe pod <pending-pod> | grep -A5 Events   # <none>
kubectl get pods -n kube-system | grep -E 'scheduler|controller|apiserver|etcd'
# kube-scheduler-cp01 이 목록에 아예 없다
```

**2단계 — static pod 은 kubelet 이 직접 띄우므로 노드로 내려갑니다.** 파드 오브젝트가 API에
나타나지도 않는다면 kubelet이 매니페스트를 읽는 단계에서 실패한 것입니다.

```bash
crictl ps -a | grep scheduler       # 아무것도 없거나 Exited
journalctl -u kubelet --since '-15min' | grep -i scheduler
```

전형적인 로그 두 유형 — 파드가 아예 생성되지 않는 경우와, 생겼지만 컨테이너가 안 뜨는 경우입니다.

```
kubelet: E ... file.go: Could not process manifest file
  "/etc/kubernetes/manifests/kube-scheduler.yaml": invalid pod: yaml: line 24: did not find expected key
kubelet: E ... CreateContainerError: error mounting "/etc/kubernetes/scheduler.conf": no such file or directory
```

| 증상 | 원인 | 확인 | 조치 |
|---|---|---|---|
| 파드가 API에 안 보임 | 매니페스트 yaml 파싱 실패 | `journalctl -u kubelet \| grep manifest` | 들여쓰기/키 수정 |
| 파드가 API에 안 보임 | 매니페스트가 디렉터리 밖으로 옮겨졌거나 점(`.`)으로 시작하는 이름으로 바뀜 | `ls -la /etc/kubernetes/manifests/` | 위치·이름 복원 |
| `crictl ps -a` 에 Exited | 잘못된 플래그 | `crictl logs <id>` | 플래그 수정 |
| `CreateContainerError` | hostPath / kubeconfig 경로 오타 | `crictl ps -a` + kubelet 로그 | 경로 수정 |
| `ImagePullBackOff` | 이미지 태그 오타 | `crictl images` | 태그 수정 |
| 파드는 Running인데 `0/1` | liveness probe 실패, 포트 충돌 | `crictl logs` | 설정 수정 |

**3단계 — 매니페스트를 고칩니다.** 원본을 먼저 보관하는데, **디렉터리 밖으로 옮깁니다.**

```bash
cp /etc/kubernetes/manifests/kube-scheduler.yaml /root/kube-scheduler.yaml.bak
vi /etc/kubernetes/manifests/kube-scheduler.yaml
```

경로 오타 예시 — `--kubeconfig` 플래그와 그 파일을 가져오는 `volumes[].hostPath.path` 는
**둘 다** 맞아야 합니다.

```yaml
# spec.containers[0].command 안
    - --kubeconfig=/etc/kubernetes/scheduler.conf     # schduler.conf 오타를 자주 낸다
# spec.volumes 안
  - name: kubeconfig
    hostPath: {path: /etc/kubernetes/scheduler.conf, type: FileOrCreate}
```

`type: FileOrCreate` 때문에 **`hostPath.path` 쪽**이 틀리면 kubelet이 그 틀린 경로에 **빈 파일을
만들어 마운트합니다.** 그러면 컨테이너는 뜨지만 스케줄러가 `invalid configuration: no configuration
has been provided` 로 즉시 죽습니다. "파일이 없다"는 에러가 아니라 "설정이 비었다"는 에러로 나타나기
때문에 경로 오타를 눈치채기 어렵습니다. (반대로 `--kubeconfig` 플래그 쪽이 틀리면 컨테이너 안에 그
파일이 없어 `no such file or directory` 로 죽습니다.) 진짜 파일은 멀쩡하므로, **엉뚱한 곳에 생긴
0바이트 파일**을 찾는 습관이 필요합니다.

```bash
ls -l /etc/kubernetes/*.conf       # 원래 파일들 옆에 0 바이트짜리(예: schduler.conf)가 보이면 그 경로가 오타다
grep -n 'scheduler.conf' /etc/kubernetes/manifests/kube-scheduler.yaml   # 플래그와 hostPath 두 곳을 대조
```

파일을 저장하면 kubelet이 변경을 감지해 **자동으로** 파드를 다시 만듭니다. 반응이 없을 때만:

```bash
systemctl restart kubelet
```

**백업을 매니페스트 디렉터리 안에 두면 안 됩니다.** kubelet은 확장자를 보지 않고 점(`.`)으로
시작하지 않는 **모든 파일**을 매니페스트로 읽습니다. `cp kube-scheduler.yaml kube-scheduler.yaml.bak`
처럼 같은 디렉터리에 백업하면 kubelet이 두 파일 모두에서 정적 파드를 만들려고 하고, 이름이 같아
충돌합니다. 원본이 깨져 있으면 백업 쪽 정의가 대신 떠서 "고쳤는데 왜 그대로지?" 하는 상황도 생깁니다.
정적 파드를 일부러 내리고 싶을 때(etcd 복구 등)는 파일을 **디렉터리 밖으로 옮깁니다.**

**5단계 — 답.** 매니페스트는 `/etc/kubernetes/manifests/kube-scheduler.yaml` 이고, static pod은
API server가 아니라 kubelet이 파일에서 직접 만들기 때문에 `kubectl delete pod` 로 지워도
kubelet이 즉시 같은 파드를 다시 만듭니다. 재시작은 파일을 수정하거나 디렉터리 밖으로
잠시 옮기는 방식으로 합니다.

## 검증

```bash
kubectl -n kube-system get pod kube-scheduler-cp01
# NAME                  READY   STATUS    RESTARTS   AGE
# kube-scheduler-cp01   1/1     Running   0          40s

curl -sk https://127.0.0.1:10259/healthz; echo    # cp01 에서 — ok (스케줄러 자체의 헬스 엔드포인트)
kubectl -n kube-system logs kube-scheduler-cp01 --tail=5 | grep -i 'leader\|serving'

# 실제로 스케줄되는지
kubectl run sched-test --image=nginx:1.27
kubectl get pod sched-test -o wide      # Running, NODE 열이 채워져야 한다
kubectl delete pod sched-test
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: static pod이 API에 아예 안 보이면 `journalctl -u kubelet` 이 유일한 단서다. `kubectl` 로는 존재하지 않는 파드를 조사할 수 없다.
- **헷갈리는 지점**: `Pending` + 이벤트 없음 = 스케줄러가 없음, `Pending` + `FailedScheduling` 이벤트 = 스케줄러는 살아 있고 조건이 안 맞음. 완전히 다른 문제입니다. 그리고 kubelet은 매니페스트 디렉터리의 `.bak` 파일도 읽으므로 백업은 반드시 디렉터리 밖에 둡니다. API server의 `/readyz` 에는 스케줄러 상태가 없으니 스케줄러 헬스는 노드에서 `:10259/healthz` 로 봅니다.

## 참고 문서

- 검색어: `static pods`
- https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/
- https://kubernetes.io/docs/tasks/debug/debug-cluster/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
