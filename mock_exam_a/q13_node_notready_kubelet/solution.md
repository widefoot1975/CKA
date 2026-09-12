# q13 — Recover a NotReady node · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

워커 노드 `worker01` 이 `NotReady` 상태다. 원인을 찾아 `Ready` 로 되돌린다.

- 클러스터의 다른 노드는 정상이다.
- 어떤 컴포넌트가 문제였고 무엇을 바꿨는지 기록한다.

## 모범 풀이

**진단은 항상 이 순서로.** 원인을 추측하지 말고 좁혀 갑니다.

```bash
# 1) 증상 확인 — Conditions 의 message 가 대부분 답을 알려줌
kubectl get nodes
kubectl describe node worker01 | grep -A10 Conditions
```

```bash
# 2) 노드에 접속해 kubelet 부터
ssh worker01
sudo -i
systemctl status kubelet
journalctl -u kubelet -n 50 --no-pager      # 여기에 진짜 원인이 나옴
```

**흔한 원인과 조치**

| 로그에 보이는 것 | 원인 | 조치 |
|---|---|---|
| `inactive (dead)` | kubelet 정지 | `systemctl enable --now kubelet` |
| `no such file or directory: /var/lib/kubelet/config.yaml` | 설정 파일 경로/삭제 | 경로 확인 후 복구 |
| `failed to run Kubelet: ... cgroup driver` | containerd와 cgroup driver 불일치 | 양쪽을 `systemd` 로 맞춤 |
| `connection refused` to `:6443` | API 서버 주소 오류 | `/etc/kubernetes/kubelet.conf` 의 server 확인 |
| `CSINode ... certificate expired` | 인증서 만료 | `kubeadm certs renew` 후 재시작 |

```bash
# 3) 컨테이너 런타임도 확인
systemctl status containerd
crictl ps

# 4) 설정 위치
cat /var/lib/kubelet/config.yaml
cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# 5) 수정 후
systemctl daemon-reload
systemctl restart kubelet
journalctl -u kubelet -f --no-pager
```

`systemctl restart` 앞에 `daemon-reload` 를 빼면 유닛 파일 수정이 반영되지 않습니다.

## 검증

```bash
kubectl get nodes                        # worker01 Ready
kubectl describe node worker01 | grep -A6 Conditions
kubectl get pods -A -o wide | grep worker01
kubectl run probe --image=nginx --overrides='{"spec":{"nodeName":"worker01"}}' \
  --restart=Never && kubectl get pod probe -o wide
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `journalctl -u kubelet` 을 먼저 본다. 추측해서 설정을 고치기 시작하면 시간을 다 씁니다.
- **헷갈리는 지점**: 노드가 NotReady인데 kubelet은 정상인 경우도 있습니다 (CNI 미설치/장애). 그때는 `kubectl -n kube-system get pods` 로 CNI 파드를 봅니다.

## 참고 문서

- 검색어: `troubleshooting clusters`
- https://kubernetes.io/docs/tasks/debug/debug-cluster/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
