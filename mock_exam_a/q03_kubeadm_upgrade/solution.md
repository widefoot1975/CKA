# q03 — Upgrade a kubeadm cluster · 풀이

← 문제: **[question.md](question.md)**

## 모범 풀이

**0) 저장소를 새 마이너 버전으로 먼저 바꿔야 합니다.** 이걸 빼면 새 버전 패키지가 아예 보이지 않습니다 — 가장 흔한 실수입니다.

```bash
vi /etc/apt/sources.list.d/kubernetes.list
# .../core:/stable:/v1.34/deb/  →  .../core:/stable:/v1.35/deb/
apt update
apt-cache madison kubeadm | head     # 설치 가능한 버전 확인
```

**1) 컨트롤 플레인**

```bash
apt-mark unhold kubeadm
apt install -y kubeadm=1.35.0-1.1
apt-mark hold kubeadm

kubeadm version
kubeadm upgrade plan
kubeadm upgrade apply v1.35.0        # 컨트롤 플레인은 apply

kubectl drain cp01 --ignore-daemonsets

apt-mark unhold kubelet kubectl
apt install -y kubelet=1.35.0-1.1 kubectl=1.35.0-1.1
apt-mark hold kubelet kubectl

systemctl daemon-reload
systemctl restart kubelet

kubectl uncordon cp01
```

**2) 워커** — `apply` 가 아니라 `upgrade node` 입니다.

```bash
# 컨트롤 플레인에서
kubectl drain worker01 --ignore-daemonsets --delete-emptydir-data

# worker01 에서
apt-mark unhold kubeadm && apt install -y kubeadm=1.35.0-1.1 && apt-mark hold kubeadm
kubeadm upgrade node
apt-mark unhold kubelet kubectl && apt install -y kubelet=1.35.0-1.1 kubectl=1.35.0-1.1 && apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet

# 컨트롤 플레인에서
kubectl uncordon worker01
```

## 검증

```bash
kubectl get nodes                  # VERSION 열이 모두 v1.35.x, STATUS 가 Ready
kubectl get nodes -o wide
kubectl -n kube-system get pods     # 컨트롤 플레인 컴포넌트 정상
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 컨트롤 플레인은 `kubeadm upgrade apply v1.x.y`, 워커는 `kubeadm upgrade node`.
- **헷갈리는 지점**: `kubeadm`만 올리고 `kubelet`을 안 올리면 노드 버전이 그대로입니다. 그리고 `systemctl daemon-reload` + `restart kubelet` 없이는 반영되지 않습니다.

## 참고 문서

- 검색어: `upgrade kubeadm clusters`
- https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
