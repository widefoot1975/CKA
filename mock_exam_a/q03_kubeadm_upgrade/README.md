# q03 — kubeadm 클러스터 업그레이드

| 항목 | 내용 |
|---|---|
| 회차 | mock_exam_a |
| 도메인 | Cluster Architecture, Installation & Configuration (25%) |
| 배점 | 6 |
| 컨텍스트 | `kubectl config use-context k8s-c2` + 노드 ssh |
| 목표 시간 | 12분 |
| 결과 | ☐ 정답 ☐ 부분 ☐ 오답 |

## 문제

클러스터를 한 마이너 버전 올린다 (예: v1.34 → v1.35).

1. 컨트롤 플레인 노드 `cp01` 을 먼저 업그레이드한다. **kubelet과 kubectl도 함께** 올린다.
2. 워커 노드 `worker01` 을 업그레이드한다.
3. 업그레이드 중 워크로드가 해당 노드에서 비워지도록 처리하고, 끝나면 다시 스케줄 가능 상태로 돌린다.
4. 모든 노드가 목표 버전으로 `Ready` 인지 확인한다.

## 내 풀이

```bash

```

<details>
<summary><b>모범 풀이</b> — 직접 풀고 나서 펼치세요</summary>

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

</details>

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
