# 시험장 치트시트

외울 것이 아니라, **모의시험 볼 때마다 실제로 쓴 것만** 남겨서 줄여 나가는 문서입니다.

## 0. 시험 시작 후 30초 안에 하는 것

```bash
alias k=kubectl
export do='--dry-run=client -o yaml'   # k run nginx --image=nginx $do > pod.yaml
export now='--force --grace-period=0'  # k delete pod nginx $now
source <(kubectl completion bash)
complete -F __start_kubectl k
```

`~/.vimrc`:

```vim
set ts=2 sw=2 et ai nu
```

> yaml 붙여넣기가 밀려서 깨지면 `:set paste` 후 붙이고 `:set nopaste`.

## 1. 문제마다 반드시

```bash
kubectl config use-context <문제가 지정한 컨텍스트>   # 이거 안 하면 0점
```

## 2. 매니페스트를 빨리 만드는 법

```bash
k run nginx --image=nginx $do > pod.yaml
k create deploy web --image=nginx --replicas=3 $do > deploy.yaml
k create job pi --image=perl -- perl -e 'print 1' $do > job.yaml
k create cj hello --image=busybox --schedule='*/1 * * * *' -- date $do > cj.yaml
k create svc clusterip web --tcp=80:80 $do > svc.yaml
k expose deploy web --port=80 --target-port=8080 --name=web-svc $do > svc.yaml
k create cm app --from-literal=k=v $do > cm.yaml
k create secret generic s1 --from-literal=pw=1234 $do > secret.yaml
k create sa builder $do > sa.yaml
k create role r1 --verb=get,list --resource=pods $do > role.yaml
k create rolebinding rb1 --role=r1 --serviceaccount=default:builder $do > rb.yaml
k create ingress web --rule='host/path=svc:80' $do > ing.yaml
```

필드 이름이 기억나지 않을 때 문서보다 빠른 방법:

```bash
k explain pod.spec.containers.resources --recursive
```

## 3. Troubleshooting (30% — 가장 큰 배점)

```bash
# 클러스터 전체 상태
k get nodes -o wide
k get pods -A -o wide --field-selector=status.phase!=Running
k get events -A --sort-by=.lastTimestamp | tail -30

# 파드
k describe pod <p>                  # Events 섹션이 답을 알려줌
k logs <p> -c <container> --previous
k exec -it <p> -- sh

# 노드가 NotReady일 때 (노드에 ssh 후)
systemctl status kubelet
journalctl -u kubelet -f --no-pager
systemctl status containerd

# 컨트롤 플레인이 죽었을 때 — 정적 파드 매니페스트 확인
ls /etc/kubernetes/manifests/
crictl ps -a
crictl logs <container-id>

# 인증 관련
ls /etc/kubernetes/           # admin.conf, kubelet.conf
```

**자주 나오는 원인**: `/etc/kubernetes/manifests/` yaml 오타, kubelet 설정 파일 경로 오류, 잘못된 `--container-runtime-endpoint`, 서비스가 파드를 못 잡는 label selector 불일치.

## 4. 노드 관리

```bash
k drain <node> --ignore-daemonsets --delete-emptydir-data
k cordon <node>
k uncordon <node>
k taint node <node> key=value:NoSchedule
k taint node <node> key-                 # 제거
```

## 5. kubeadm 업그레이드 순서

```bash
# (1) 새 마이너 버전 repo로 먼저 바꿔야 함 — 이걸 빼면 패키지가 안 보임
vi /etc/apt/sources.list.d/kubernetes.list   # .../core:/stable:/v1.NN/deb/

# (2) 컨트롤 플레인
apt update
apt-mark unhold kubeadm && apt install -y kubeadm=1.NN.X-* && apt-mark hold kubeadm
kubeadm upgrade plan
kubeadm upgrade apply v1.NN.X

k drain <cp-node> --ignore-daemonsets
apt-mark unhold kubelet kubectl && apt install -y kubelet=1.NN.X-* kubectl=1.NN.X-* && apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet
k uncordon <cp-node>

# (3) 워커 (apply 대신 node)
kubeadm upgrade node
```

## 6. etcd 백업 / 복구

```bash
# 백업
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /opt/backup.db

# 확인
etcdutl --write-out=table snapshot status /opt/backup.db

# 복구 (etcd 3.5+ 는 etcdctl 대신 etcdutl 권장)
etcdutl snapshot restore /opt/backup.db --data-dir=/var/lib/etcd-restore
# 그 다음 /etc/kubernetes/manifests/etcd.yaml 의 hostPath 를 새 data-dir 로 수정
# → 정적 파드가 자동 재시작될 때까지 대기
```

인증서 경로는 `/etc/kubernetes/manifests/etcd.yaml`에서 확인하는 게 확실합니다.

## 7. 자주 쓰는 조회

```bash
k get po -A --sort-by=.metadata.creationTimestamp
k get po -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.podIP}{"\n"}{end}'
k top node; k top pod -A
k get po -l app=web --show-labels
k auth can-i get pods --as=system:serviceaccount:default:builder
```

## 8. 시간 관리

- 배점이 큰 문제부터. 화면에 배점이 표시됩니다.
- 3분 안에 진입점이 안 보이면 **flag 걸고 넘어갑니다.**
- 마지막 10분은 새 문제를 풀지 않고 검증에만 씁니다.
