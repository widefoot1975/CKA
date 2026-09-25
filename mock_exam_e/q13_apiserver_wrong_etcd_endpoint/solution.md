# q13 — API server down after a machine migration · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

단일 노드 클러스터 `k8s-c2` 를 새 머신 `cp01` 로 옮겼다. 옮긴 뒤로 모든 `kubectl` 명령이
`The connection to the server ... was refused` 로 실패한다. `cp01` 의 etcd와 kubelet은 정상 실행 중이다.

1. `cp01` 에서 kube-apiserver가 계속 떠 있지 못하는 이유를 찾는다. API server가 동작하기 전에는
   `kubectl` 이 도움이 되지 않으므로 컨테이너 런타임과 static pod 매니페스트를 사용한다.
2. kube-apiserver static pod 매니페스트를 고친다. 원본 파일의 백업 사본은 `/etc/kubernetes/manifests`
   밖에 둔다.
3. 찾아낸 잘못된 설정값을 `/opt/course/e13/cause.txt` 에 적는다.
4. `kubectl get nodes` 가 다시 동작하고 `cp01` 이 `Ready` 로 보이는지 확인한다.

## 모범 풀이

**API server가 없으면 `kubectl` 은 아무것도 보지 못합니다.** kube-apiserver는 kubelet이
`/etc/kubernetes/manifests/` 의 파일로 직접 띄우는 static pod이므로, 노드에서 컨테이너 런타임으로 봅니다.

**1) 컨테이너 상태와 로그**

```bash
crictl ps -a | grep -E 'kube-apiserver|etcd'
# CONTAINER  ...  CREATED         STATE    NAME            ATTEMPT  ...
# 9c1e0f...  ...  30 seconds ago  Exited   kube-apiserver  7        ...
# 4b7a2d...  ...  2 hours ago     Running  etcd            0        ...
crictl logs <가장 최근 kube-apiserver 컨테이너 ID> 2>&1 | tail -5
# ... addrConn.createTransport failed to connect to {Addr: "10.0.5.20:2379", ...}
#     ... dial tcp 10.0.5.20:2379: i/o timeout
# ... Error creating leases: error creating storage factory: context deadline exceeded     ← 예시
```

`crictl ps` 는 실행 중인 것만 보여 주므로 `-a` 를 붙입니다. etcd에 붙지 못한 API server는 곧 종료되고
kubelet이 다시 띄우기를 반복합니다(ATTEMPT 증가). 결정적 단서는 `dial tcp 10.0.5.20:2379` 입니다 —
etcd는 이 머신에서 잘 돌고 있는데 API server는 옛 머신 주소의 etcd에 접속하려 합니다.

**2) 매니페스트 확인과 수정**

```bash
grep -n 'etcd-servers' /etc/kubernetes/manifests/kube-apiserver.yaml
#     - --etcd-servers=https://10.0.5.20:2379          ← 옛 머신 주소 (IP 는 예시)
grep -n 'listen-client-urls' /etc/kubernetes/manifests/etcd.yaml
#     - --listen-client-urls=https://127.0.0.1:2379,https://<cp01 IP>:2379
```

kubeadm의 stacked 구성에서 API server는 같은 노드의 etcd에 `https://127.0.0.1:2379` 로 붙습니다.
etcd도 127.0.0.1에서 대기 중이니 그 값으로 바꿉니다.

```bash
cp /etc/kubernetes/manifests/kube-apiserver.yaml /root/kube-apiserver.yaml.bak   # 디렉터리 밖에 백업
sed -i 's#--etcd-servers=.*#--etcd-servers=https://127.0.0.1:2379#' /etc/kubernetes/manifests/kube-apiserver.yaml
grep -rn '10.0.5.20' /etc/kubernetes/manifests/     # 옛 주소가 다른 곳에 더 남아 있지 않은지
```

파일을 저장하면 kubelet이 변경을 감지해 파드를 새로 만듭니다. `kubectl apply` 도 kubelet 재시작도
필요 없습니다. 백업을 `/etc/kubernetes/manifests/` 안에 두면 안 됩니다 — kubelet은 확장자와 상관없이
점(`.`)으로 시작하지 않는 모든 파일을 매니페스트로 읽기 때문에 `.bak` 파일도 static pod으로 띄우려 합니다.

**3) 원인 기록**

```bash
mkdir -p /opt/course/e13
echo 'https://10.0.5.20:2379' > /opt/course/e13/cause.txt      # 1)~2)에서 찾은 값 그대로
```

## 검증

```bash
crictl ps | grep kube-apiserver                  # Running, 새 컨테이너 (준비까지 30초~1분)
export KUBECONFIG=/etc/kubernetes/admin.conf     # root 에 kubeconfig 가 없으면
kubectl get nodes
# NAME   STATUS   ROLES           AGE   VERSION
# cp01   Ready    control-plane   40d   v1.35.x
kubectl -n kube-system get pod kube-apiserver-cp01     # 1/1 Running
cat /opt/course/e13/cause.txt                    # https://10.0.5.20:2379
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `kubectl` 이 connection refused면 노드에서 `crictl ps -a` → `crictl logs <id>` → `/etc/kubernetes/manifests/kube-apiserver.yaml` 순서로 본다. stacked etcd의 주소는 `--etcd-servers=https://127.0.0.1:2379`.
- **헷갈리는 지점**: `connection refused` 는 "6443 포트에서 아무도 받지 않는다"는 뜻이라 kubeconfig나 인증서가 아니라 API server 프로세스 자체를 봐야 합니다. 컨테이너가 너무 빨리 사라져 `crictl logs` 가 어렵다면 `/var/log/pods/kube-system_kube-apiserver-cp01_*/kube-apiserver/` 의 로그 파일을 읽습니다.

## 참고 문서

- 검색어: `static pods`, `debugging kubernetes nodes with crictl`
- https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/
- https://kubernetes.io/docs/tasks/debug/debug-cluster/crictl/
- https://kubernetes.io/docs/tasks/debug/debug-cluster/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
