# q01 — Verify and operate a highly-available control plane · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`k8s-c3` 클러스터는 stacked HA 컨트롤 플레인이다. 현재 `cp01` 과 `cp02` 만 join되어 있고,
재설치된 `cp03` 을 다시 넣어야 한다.

1. `cp01` 에서 etcd 서버 인증서로 `etcdctl` member list를 출력한다. **현재** 멤버 수와 이
   클러스터가 견딜 수 있는 멤버 장애 수를 `/opt/q01/quorum.txt` 에 적는다.
2. `cp01` 에서 `cp03` 이 **컨트롤 플레인 노드로** join할 수 있는 명령을 만든다. 새로 업로드한
   certificate key를 포함해야 한다. `/opt/q01/join.sh` 에 적고 실행하지는 않는다.
3. `cp02` 를 점검용으로 drain한다. DaemonSet 파드는 남기고 emptyDir 볼륨을 쓰는 파드는 evict를
   허용한다. 끝나면 다시 스케줄 가능 상태로 되돌린다.
4. `cp01` 을 올리는 `kubeadm` 하위 명령과 `cp02`, `cp03` 을 올리는 하위 명령을
   `/opt/q01/upgrade.txt` 에 적는다.
5. 모든 컨트롤 플레인 노드가 `Ready` 이고 모든 etcd 멤버가 endpoint health에 응답하는지 확인한다.

## 모범 풀이

**1) etcd 멤버 확인.** etcd는 static pod이므로 호스트의 인증서 경로를 그대로 씁니다.

```bash
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  member list -w table
```

호스트에 `etcdctl` 이 없으면 파드 안에서 실행합니다.

```bash
kubectl -n kube-system exec etcd-cp01 -- etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key member list
```

정족수는 `(N/2)+1` 입니다. 멤버가 2개면 정족수가 2이므로 **한 대만 죽어도 쓰기가 멈춥니다.**
견딜 수 있는 장애는 0개입니다. `cp03` 이 들어와 3개가 되면 정족수 2, 장애 1개를 견딥니다.
그래서 HA etcd는 항상 홀수로 맞춥니다 — 짝수는 정족수를 올리지 않으면서 고장 날 대상만 늘립니다.

```
members: 2, tolerated failures: 0   (3 members -> 1)
```

**2) join 명령.** 여기서 두 가지가 각각 따로 만료된다는 점이 핵심입니다. bootstrap token은
24시간, `kubeadm-certs` Secret에 올라간 certificate key는 **2시간**이면 사라집니다. 그래서
명령 두 개를 모두 다시 실행해야 합니다.

```bash
kubeadm init phase upload-certs --upload-certs     # 새 certificate key 출력
kubeadm token create --print-join-command          # 새 token + ca-cert-hash 출력
```

두 출력을 합쳐 `/opt/q01/join.sh` 에 씁니다.

```bash
kubeadm join 192.168.100.10:6443 --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash> \
  --control-plane --certificate-key <key>
```

`--control-plane` 을 빼면 워커로 들어가고, `--certificate-key` 를 빼면 인증서를 못 받아
`error execution phase control-plane-prepare/download-certs` 로 실패합니다.

**3) drain**

```bash
kubectl drain cp02 --ignore-daemonsets --delete-emptydir-data
kubectl uncordon cp02
```

**4) 업그레이드 주체.** 첫 컨트롤 플레인만 `apply` 이고, 나머지는 `node` 입니다.

```
cp01: kubeadm upgrade apply v1.35.x
cp02, cp03: kubeadm upgrade node
```

## 검증

```bash
kubectl get nodes -l node-role.kubernetes.io/control-plane
# cp01 Ready control-plane / cp02 Ready control-plane

ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key endpoint health --cluster -w table
# 각 endpoint 가 health: true, ERROR 열이 비어 있어야 한다

kubectl get --raw='/readyz?verbose' | tail -5     # 모든 check 가 ok
kubectl -n kube-system get secret kubeadm-certs   # upload-certs 직후에만 존재
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: certificate key는 2시간, bootstrap token은 24시간 뒤 만료된다. 컨트롤 플레인 join은 `kubeadm init phase upload-certs --upload-certs` + `kubeadm token create --print-join-command` 두 명령이 모두 필요하다.
- **헷갈리는 지점**: 첫 노드는 `kubeadm upgrade apply <version>`, 두 번째 이후 컨트롤 플레인과 워커는 `kubeadm upgrade node` 입니다. `apply` 를 두 번째 노드에서 실행하면 클러스터 전체 버전을 다시 올리려 들면서 거부됩니다. 그리고 멤버 2개짜리 etcd는 단일 노드보다 안전하지 않습니다.

## 참고 문서

- 검색어: `creating highly available clusters with kubeadm`
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/
- https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
