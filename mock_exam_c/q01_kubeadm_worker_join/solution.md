# q01 — Join a new worker node to the cluster · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

새로 준비된 머신 `worker03` 에 `kubeadm`, `kubelet`, `containerd` 는 설치되어 있으나 아직 어떤
클러스터에도 조인하지 않았다. 이 노드를 워커로 클러스터에 편입시킨다.

1. `worker03` 에서 노드 전제조건을 확인한다: swap 비활성, `br_netfilter` 모듈 로드,
   `net.ipv4.ip_forward` 가 `1`, containerd의 runc가 `SystemdCgroup = true`.
   잘못된 것은 고친다.
2. `cp01` 에서 기존 부트스트랩 토큰 목록을 본다. 기존 토큰은 만료되었으므로 재사용하지 않는다.
3. `cp01` 에서 join 명령을 손으로 조립하지 않고 만들어 낸다.
4. `/etc/kubernetes/pki/ca.crt` 로부터 discovery CA 인증서 해시를 직접 계산해서
   join 명령 안의 해시와 일치하는지 확인한다.
5. `worker03` 에서 join을 실행하고 노드에 `node-role.kubernetes.io/worker=worker`
   레이블을 붙인다.
6. `worker03` 이 `Ready` 가 되고 테스트 파드가 그 노드에 스케줄되는지 확인한다.

## 모범 풀이

**1) 전제조건** (worker03, root)

```bash
swapoff -a && sed -i '/ swap / s/^/#/' /etc/fstab      # fstab까지 고쳐야 재부팅 후에도 유지
lsmod | grep br_netfilter || modprobe br_netfilter
echo br_netfilter > /etc/modules-load.d/k8s.conf
sysctl net.ipv4.ip_forward                            # 0이면 아래로 수정
printf 'net.ipv4.ip_forward=1\nnet.bridge.bridge-nf-call-iptables=1\n' > /etc/sysctl.d/k8s.conf
sysctl --system
grep -n SystemdCgroup /etc/containerd/config.toml     # false면 true로
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
```

**2~3) 토큰과 join 명령** (cp01, root)

```bash
kubeadm token list                                     # 만료 확인
kubeadm token create --print-join-command
# kubeadm join 10.0.0.10:6443 --token abcdef.0123456789abcdef \
#     --discovery-token-ca-cert-hash sha256:1a2b3c...
```

`--print-join-command` 는 토큰을 새로 만들면서 API 서버 주소와 CA 해시까지 채워 출력합니다.
해시를 외워서 적을 필요가 없습니다.

**4) CA 해시 직접 계산** (cp01)

```bash
openssl x509 -in /etc/kubernetes/pki/ca.crt -pubkey -noout \
  | openssl pkey -pubin -outform der \
  | openssl dgst -sha256 -hex | sed 's/^.* //'
```

핵심은 **인증서 전체가 아니라 공개키(SubjectPublicKeyInfo)의 DER 인코딩**을 해싱한다는 점입니다.
`openssl x509 -in ca.crt -outform der | openssl dgst -sha256` 로 하면 전혀 다른 값이 나옵니다.

**5) 조인**

```bash
# worker03 에서 위에서 받은 명령을 그대로 실행
kubeadm join 10.0.0.10:6443 --token abcdef.0123456789abcdef \
  --discovery-token-ca-cert-hash sha256:1a2b3c...

# cp01 에서
kubectl label node worker03 node-role.kubernetes.io/worker=worker
```

조인 실패 시 `kubeadm reset -f` 로 되돌린 뒤 다시 시도합니다. 그냥 재실행하면
"file already exists" 류 오류로 막힙니다.

## 검증

```bash
kubectl get nodes -o wide
# worker03   Ready   worker   ...   v1.35.x

kubectl run t1 --image=nginx --overrides='{"spec":{"nodeName":"worker03"}}'
kubectl get pod t1 -o wide          # NODE 칼럼이 worker03, STATUS Running

kubectl -n kube-system get pods -o wide | grep worker03
# kube-proxy / CNI 데몬셋 파드가 새 노드에 떠 있어야 한다

kubeadm token list                  # 새 토큰이 24h TTL로 보인다
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: join 명령은 만들지 말고 `kubeadm token create --print-join-command` 로 받는다.
- **헷갈리는 지점**: `kubeadm token list` 에 보이는 것은 부트스트랩 토큰이고,
  `--certificate-key` 는 컨트롤 플레인 조인에만 쓰이는 별개의 값입니다
  (`kubeadm init phase upload-certs --upload-certs` 로 생성). 워커 조인에는 필요 없습니다.
  swap도 함정입니다 — `swapoff -a` 만 하고 `/etc/fstab` 을 그대로 두면 재부팅 후 kubelet이 다시 죽습니다.

## 참고 문서

- 검색어: `kubeadm join`
- https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
