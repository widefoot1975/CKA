# q16 — Control plane down due to a static pod manifest error · 풀이

← 문제: **[question.md](question.md)**

## 모범 풀이

kubectl이 안 되므로 **컨테이너 런타임 레벨(`crictl`)에서 봐야 합니다.**

```bash
ssh <control-plane>
sudo -i

# 1) kubelet 로그 — 매니페스트 파싱 오류가 여기 그대로 찍힘
journalctl -u kubelet -n 50 --no-pager | grep -i -E 'error|apiserver|manifest'

# 2) 컨테이너 상태 — Exited 된 apiserver 를 찾는다
crictl ps -a | grep apiserver
crictl logs <container-id>            # 여기에 진짜 원인

# 3) 정적 파드 매니페스트 확인
ls -l /etc/kubernetes/manifests/
```

**흔한 원인**

| 증상 | 원인 |
|---|---|
| kubelet 로그에 yaml 파싱 에러 | 매니페스트 들여쓰기/오타 |
| `unknown flag: --xxx` | 존재하지 않는 플래그 추가 |
| `no such file or directory` | 인증서·볼륨 경로 오타 |
| `bind: address already in use` | 포트 충돌 |
| apiserver 컨테이너가 생기지도 않음 | 매니페스트가 디렉터리 밖에 있음 |

```bash
# 4) 수정 — 반드시 백업부터
cp /etc/kubernetes/manifests/kube-apiserver.yaml /root/kube-apiserver.yaml.bak
vi /etc/kubernetes/manifests/kube-apiserver.yaml

# 문법 검사
python3 -c "import yaml;yaml.safe_load(open('/etc/kubernetes/manifests/kube-apiserver.yaml'))"

# 5) 반영 대기 — kubelet 이 자동 감지 (재시작 명령 불필요)
watch crictl ps | grep apiserver
```

**정적 파드는 `kubectl apply` 로 다시 만들 수 없습니다.** kubelet이 `/etc/kubernetes/manifests/` 를 감시하며 직접 띄우므로, 파일을 고치고 기다리는 게 유일한 방법입니다. 파일을 디렉터리 밖으로 옮기면 파드가 사라지고, 다시 넣으면 살아납니다 — 강제 재시작이 필요할 때 쓰는 방법입니다.

```bash
mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/ && sleep 20
mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/
```

## 검증

```bash
kubectl get nodes                       # 응답이 돌아옴
kubectl -n kube-system get pods | grep -E 'apiserver|scheduler|controller|etcd'
crictl ps | grep apiserver              # Running
journalctl -u kubelet -n 20 --no-pager  # 새 에러 없음
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: kubectl이 죽었을 때의 도구는 `journalctl -u kubelet` 과 `crictl`. 이 두 개로 들어갑니다.
- **헷갈리는 지점**: 수정 후 kubelet을 재시작할 필요가 없습니다. 파일 변경만으로 자동 반영되며, 1~2분 걸릴 수 있어 성급하게 다시 고치면 상황이 꼬입니다.

## 참고 문서

- 검색어: `static pod`
- https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
