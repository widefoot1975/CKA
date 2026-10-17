# q13 — Cluster DNS resolution is failing

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` (→ `ssh <node>` if needed) |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기** (트러블슈팅 문제라 명령어에 답이 보인다. 미리 보고 싶지 않으면 방법 B 를 쓴다)

<details><summary>설정 명령 펼치기 (답 포함)</summary>

```bash
# 0) 처음 실행할 때 원본 Corefile 을 보관하고, 그다음부터는 그 원본으로 되돌린다 (= 이전 실습 흔적 정리)
#    원본 파일 없이 이 문제의 고장이 남아 있으면 그 한 글자를 되돌려서 보관한다
ORIG=/opt/course/c13-corefile.orig
mkdir -p /opt/course
if [ -f "$ORIG" ]; then
  kubectl -n kube-system create cm coredns --from-file=Corefile="$ORIG" --dry-run=client -o yaml | kubectl replace -f -
  kubectl -n kube-system rollout restart deploy coredns
else
  kubectl -n kube-system get cm coredns -o jsonpath='{.data.Corefile}' \
    | sed -E 's/^([[:space:]]*)kubernets([[:space:]])/\1kubernetes\2/' > "$ORIG"
fi
# e16 실습이 레플리카 0 으로 남겨 두었으면 kubeadm 기본값 2 로 (파드가 있어야 이 문제의 증상이 보인다)
if [ "$(kubectl -n kube-system get deploy coredns -o jsonpath='{.spec.replicas}')" = "0" ]; then
  kubectl -n kube-system scale deploy coredns --replicas=2
fi
kubectl -n kube-system rollout status deploy coredns --timeout=120s
rm -rf /opt/course/q13

# 1) 확인용 Service backend.app (namespace app 은 f09 도 쓰므로 이 문제 것에만 라벨 course=c13 을 단다)
if ! kubectl get ns app >/dev/null 2>&1; then
  kubectl create ns app
  kubectl label ns app course=c13
fi
kubectl -n app delete deploy,svc -l course=c13 --ignore-not-found --wait=true
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: app
  labels: {course: c13}
spec:
  replicas: 1
  selector:
    matchLabels: {c13: backend}
  template:
    metadata:
      labels: {c13: backend}
    spec:
      containers:
      - name: web
        image: nginx:1.27
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: app
  labels: {course: c13}
spec:
  selector: {c13: backend}
  ports:
  - port: 80
    targetPort: 80
YAML
kubectl -n app rollout status deploy backend --timeout=120s

# 2) 장애 만들기 (내용은 풀이에서 확인)
sed -E 's/^([[:space:]]*)kubernetes([[:space:]])/\1kubernets\2/' "$ORIG" > /opt/course/c13-corefile.broken
kubectl -n kube-system create cm coredns --from-file=Corefile=/opt/course/c13-corefile.broken --dry-run=client -o yaml | kubectl replace -f -
rm -f /opt/course/c13-corefile.broken
kubectl -n kube-system delete pod -l k8s-app=kube-dns --wait=false
for i in $(seq 1 40); do
  R=$(kubectl -n kube-system get pod -l k8s-app=kube-dns \
        -o jsonpath='{range .items[*]}{.status.containerStatuses[0].restartCount}{"\n"}{end}' 2>/dev/null | sort -n | head -1 || true)
  [ -n "$R" ] && [ "$R" -ge 1 ] && break
  sleep 3
done
kubectl -n kube-system get pods -l k8s-app=kube-dns

# 3) 시작 상태 확인: 파드 IP 로는 닿지만 이름은 해석되지 않는다
BIP=$(kubectl -n app get pod -l c13=backend -o jsonpath='{.items[0].status.podIP}')
echo "backend 파드 IP: $BIP"
kubectl delete pod c13-check --ignore-not-found --wait=true
kubectl run c13-check --rm -i --restart=Never --image=busybox:1.36 -- sh -c \
  "wget -qO- -T 3 http://$BIP >/dev/null && echo 'pod IP: OK'; nslookup backend.app.svc.cluster.local || echo 'name: FAIL (정상)'" || true
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

setup 을 처음 실행할 때 지금의 Corefile 을 `/opt/course/c13-corefile.orig` 에 보관하고, 다시 실행하거나 `cleanup.sh` 를 돌리면 그 원본으로 되돌린 뒤 CoreDNS 를 재시작한다. 그래서 setup 을 처음 돌리기 **전에** Corefile 을 직접 고쳐 두었다면 먼저 원래대로 돌려 놓는다. CoreDNS 레플리카가 0 이면(e16 실습을 정리하지 않은 상태) kubeadm 기본값 2 로 되돌린다.
설정이 끝나면 **클러스터의 모든 파드가 DNS 이름을 해석하지 못한다.** 확인용으로 namespace `app` 에 Service `backend` 와 nginx 파드 하나를 만든다. 파드 IP 는 문제의 `10.244.2.14` 와 다를 수 있으니 setup 이 출력한 값을 쓴다.
namespace `app` 은 f09 도 쓴다. 이 문제가 만든 리소스에는 라벨 `course=c13` 이 붙고, `cleanup.sh` 는 그것만 지운다(namespace 는 이 문제가 만들었을 때만 지운다). 실습이 끝나면 **반드시 `cleanup.sh`** 로 Corefile 을 되돌린다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
ORIG=/opt/course/c13-corefile.orig
if [ -f "$ORIG" ]; then
  kubectl -n kube-system create cm coredns --from-file=Corefile="$ORIG" --dry-run=client -o yaml | kubectl replace -f -
  kubectl -n kube-system rollout restart deploy coredns
  kubectl -n kube-system rollout status deploy coredns --timeout=120s
  rm -f "$ORIG"
fi

# namespace app 은 이 문제가 만든 것(라벨 course=c13)일 때만 지운다. f09 가 만든 것이면 이 문제 리소스만 지운다.
kubectl -n app delete deploy,svc -l course=c13 --ignore-not-found
if [ "$(kubectl get ns app -o jsonpath='{.metadata.labels.course}' 2>/dev/null || true)" = "c13" ]; then
  kubectl delete ns app --ignore-not-found
fi
rm -rf /opt/course/q13
```

</details>

## Task

Pods across the cluster cannot resolve any name. `curl http://backend.app.svc.cluster.local`
fails with a lookup error from inside every pod, but `curl http://10.244.2.14` (a pod IP)
works. External names such as `kubernetes.io` also fail.

1. Confirm from inside a pod that this is a DNS failure and not a routing failure.
2. Work out which layer is broken: the pod's resolver config, the `kube-dns` Service, the
   CoreDNS pods, or the CoreDNS configuration.
3. Fix the cluster so that both in-cluster Service names and external names resolve.
4. Write the root cause in one sentence to `/opt/course/q13/cause.txt`.
5. Do not delete the `kube-dns` Service and do not change any pod's `dnsPolicy`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
