# q02 — Upgrade the cluster lifecycle with kubeadm · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

클러스터가 v1.34로 동작 중이다. v1.35로 올린다.

1. 업그레이드를 적용하기 **전에**, kubeadm이 제안하는 v1.35 업그레이드 계획을 보인다.
2. 컨트롤 플레인 노드 `cp01` 을 업그레이드한다. `kubelet` 과 `kubectl` 도 포함한다.
3. 워커 노드 `worker01` 을 업그레이드한다.
4. 각 노드는 kubelet을 교체하기 전에 drain하고, 끝나면 다시 스케줄 가능 상태로 되돌린다.
5. 모든 노드가 v1.35이고 `Ready` 인지, 컨트롤 플레인 컴포넌트에 실패가 없는지 확인한다.

워커가 컨트롤 플레인과 다른 kubeadm 하위 명령을 쓰는 이유를 한 줄로 적는다.

## 모범 풀이

`kubectl` 명령은 작업 호스트(`ssh k8s-c2`)에서, `apt`·`kubeadm`·`systemctl` 은 각 노드에서 root로
실행합니다.

**0) cp01 — 저장소를 새 마이너 버전으로 바꿉니다.** 이걸 빼면 새 패키지가 보이지 않습니다 — 가장 흔한 실수입니다.

```bash
vi /etc/apt/sources.list.d/kubernetes.list
# .../core:/stable:/v1.34/deb/  →  .../core:/stable:/v1.35/deb/
apt update
apt-cache madison kubeadm | head -3     # 설치할 1.35 패치 버전 확인 (아래는 1.35.0-1.1 로 가정)
```

**1) cp01 — kubeadm 을 먼저 올리고, 적용 전에 계획을 봅니다**

```bash
apt-mark unhold kubeadm && apt install -y kubeadm=1.35.0-1.1 && apt-mark hold kubeadm
kubeadm version
kubeadm upgrade plan                    # ← 1번 답. 적용 전에 목표 버전과 컴포넌트별 변경을 보여 준다
kubeadm upgrade apply v1.35.0           # 첫 컨트롤 플레인은 apply
```

공식 절차는 **kubeadm 바이너리를 먼저 올린 뒤** `plan` 을 봅니다. 1.34 kubeadm으로 `plan` 을 돌리면
새 마이너가 보이지 않거나 "kubeadm을 먼저 올리라"는 안내만 나옵니다.

**2) cp01 — drain 후 kubelet·kubectl**

```bash
kubectl drain cp01 --ignore-daemonsets --delete-emptydir-data   # 작업 호스트에서

apt-mark unhold kubelet kubectl
apt install -y kubelet=1.35.0-1.1 kubectl=1.35.0-1.1
apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet

kubectl uncordon cp01                   # 작업 호스트에서
```

**3) 워커 — 저장소 변경은 노드마다 따로 해야 합니다**

apt 저장소 설정은 노드 로컬 파일입니다. cp01에서 바꿨다고 worker01이 새 패키지를 보는 게 아니므로,
여기서 다시 바꾸지 않으면 `apt install kubeadm=1.35...` 가 `Version ... was not found` 로 실패합니다.

```bash
# worker01 에서
vi /etc/apt/sources.list.d/kubernetes.list   # v1.34 → v1.35
apt update
apt-mark unhold kubeadm && apt install -y kubeadm=1.35.0-1.1 && apt-mark hold kubeadm
kubeadm upgrade node                         # 워커는 node

kubectl drain worker01 --ignore-daemonsets --delete-emptydir-data   # 작업 호스트에서

# worker01 에서
apt-mark unhold kubelet kubectl && apt install -y kubelet=1.35.0-1.1 kubectl=1.35.0-1.1 && apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet

kubectl uncordon worker01                    # 작업 호스트에서
```

**왜 하위 명령이 다른가**: `upgrade apply` 는 컨트롤 플레인 컴포넌트의 정적 파드 매니페스트와 클러스터 설정(ClusterConfiguration)을 실제로 바꾸는 작업이라 첫 컨트롤 플레인 노드에서 한 번만 수행합니다. 워커에는 바꿀 컨트롤 플레인이 없고 kubelet 설정만 새 버전에 맞추면 되므로 `upgrade node` 를 씁니다. 컨트롤 플레인이 여러 대인 경우 **두 번째 이후 컨트롤 플레인 노드도 `upgrade node`** 입니다.

## 검증

```bash
kubectl get nodes                      # VERSION 전부 v1.35.x, STATUS Ready
kubectl -n kube-system get pods        # apiserver/scheduler/controller-manager/etcd 정상
kubeadm upgrade plan                   # (cp01) 더 올릴 것이 없다고 나옴
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.nodeInfo.kubeletVersion}{"\n"}{end}'
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: (노드마다) 저장소 URL 변경 → kubeadm → plan → apply/node → drain → kubelet·kubectl → daemon-reload·restart → uncordon. 순서가 곧 점수입니다.
- **헷갈리는 지점**: `kubeadm` 만 올리고 `kubelet` 을 빼먹으면 `kubectl get nodes` 의 VERSION이 그대로입니다. 저장소 변경은 노드 로컬 설정이라 **워커에서도** 다시 해야 합니다. 그리고 `systemctl daemon-reload` 없이 restart하면 유닛 변경이 반영되지 않습니다.

## 참고 문서

- 검색어: `upgrade kubeadm clusters`
- https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/
- https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/upgrading-linux-nodes/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
