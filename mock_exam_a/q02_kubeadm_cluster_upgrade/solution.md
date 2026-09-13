# q02 — Upgrade the cluster lifecycle with kubeadm · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

클러스터가 v1.34로 동작 중이다. v1.35로 올린다.

1. 아무것도 바꾸기 **전에**, kubeadm이 이 클러스터를 어떤 버전으로 올릴 수 있는지 확인한다.
2. 컨트롤 플레인 노드 `cp01` 을 업그레이드한다. `kubelet` 과 `kubectl` 도 포함한다.
3. 워커 노드 `worker01` 을 업그레이드한다.
4. 각 노드는 kubelet을 교체하기 전에 drain하고, 끝나면 다시 스케줄 가능 상태로 되돌린다.
5. 모든 노드가 v1.35이고 `Ready` 인지, 컨트롤 플레인 컴포넌트에 실패가 없는지 확인한다.

워커가 컨트롤 플레인과 다른 kubeadm 하위 명령을 쓰는 이유를 한 줄로 적는다.

## 모범 풀이

**0) 저장소를 새 마이너 버전으로 먼저 바꿉니다.** 이걸 빼면 새 패키지가 보이지 않습니다 — 가장 흔한 실수입니다.

```bash
vi /etc/apt/sources.list.d/kubernetes.list
# .../core:/stable:/v1.34/deb/  →  .../core:/stable:/v1.35/deb/
apt update
apt-cache madison kubeadm | head -3
```

**1) 업그레이드 가능 버전 확인**

```bash
kubeadm upgrade plan
```

**2) 컨트롤 플레인**

```bash
apt-mark unhold kubeadm && apt install -y kubeadm=1.35.0-1.1 && apt-mark hold kubeadm
kubeadm version
kubeadm upgrade apply v1.35.0          # 컨트롤 플레인은 apply

kubectl drain cp01 --ignore-daemonsets
apt-mark unhold kubelet kubectl
apt install -y kubelet=1.35.0-1.1 kubectl=1.35.0-1.1
apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet
kubectl uncordon cp01
```

**3) 워커**

```bash
kubectl drain worker01 --ignore-daemonsets --delete-emptydir-data   # 컨트롤 플레인에서

# worker01 에서
apt-mark unhold kubeadm && apt install -y kubeadm=1.35.0-1.1 && apt-mark hold kubeadm
kubeadm upgrade node                    # 워커는 node
apt-mark unhold kubelet kubectl && apt install -y kubelet=1.35.0-1.1 kubectl=1.35.0-1.1 && apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet

kubectl uncordon worker01               # 컨트롤 플레인에서
```

**왜 하위 명령이 다른가**: `upgrade apply` 는 컨트롤 플레인 컴포넌트의 정적 파드 매니페스트와 클러스터 설정(ClusterConfiguration)을 실제로 바꾸는 작업이라 첫 컨트롤 플레인 노드에서 한 번만 수행합니다. 워커에는 바꿀 컨트롤 플레인이 없고 kubelet 설정만 새 버전에 맞추면 되므로 `upgrade node` 를 씁니다. 컨트롤 플레인이 여러 대인 경우 **두 번째 이후 컨트롤 플레인 노드도 `upgrade node`** 입니다.

## 검증

```bash
kubectl get nodes                      # VERSION 전부 v1.35.x, STATUS Ready
kubectl -n kube-system get pods        # apiserver/scheduler/controller-manager/etcd 정상
kubeadm upgrade plan                   # 더 올릴 것이 없다고 나옴
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.nodeInfo.kubeletVersion}{"\n"}{end}'
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 저장소 URL 변경 → kubeadm → apply/node → drain → kubelet·kubectl → daemon-reload·restart → uncordon. 순서가 곧 점수입니다.
- **헷갈리는 지점**: `kubeadm` 만 올리고 `kubelet` 을 빼먹으면 `kubectl get nodes` 의 VERSION이 그대로입니다. 그리고 `systemctl daemon-reload` 없이 restart하면 유닛 변경이 반영되지 않습니다.

## 참고 문서

- 검색어: `upgrade kubeadm clusters`
- https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
