# q17 — Service traffic broken by kube-proxy

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh worker01`, then `sudo -i` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

이 문제는 **클러스터를 일부러 고장 낸 상태에서** 시작한다. `k8s-c1` 에서 아래 둘 중 하나를 실행한다(노드에 ssh 할 필요 없음). 여러 번 실행해도 안전하다. 실습이 끝나면 반드시 정리(cleanup)해서 kube-proxy 를 원래대로 돌려놓는다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기** (트러블슈팅 문제라 명령어에 답이 보인다. 미리 보고 싶지 않으면 방법 B 를 쓴다)

<details><summary>설정 명령 펼치기 (답 포함)</summary>

```bash
NODE=worker01     # 문제 노드 이름이 다르면 여기만 바꾼다
DS="-n kube-system ds/kube-proxy"

# 0) 이전 실습 흔적 정리: kube-proxy 를 모든 노드로 되돌리고 이 문제의 리소스만 지운다
#    (namespace app 은 다른 문제도 쓰므로 통째로 지우지 않는다)
if kubectl get $DS -o jsonpath='{.spec.template.spec.nodeSelector}' | grep -q '"kube-proxy"'; then
  kubectl patch $DS --type=json -p='[{"op":"remove","path":"/spec/template/spec/nodeSelector/kube-proxy"}]'
fi
kubectl label nodes --all kube-proxy- >/dev/null 2>&1 || true
kubectl -n kube-system delete pod c17-reboot-sim --ignore-not-found
kubectl rollout status $DS --timeout=180s
kubectl create ns app --dry-run=client -o yaml | kubectl apply -f -
kubectl -n app delete deploy web --ignore-not-found
kubectl -n app delete svc web web-np --ignore-not-found
kubectl -n app delete pod client dbg v v2 --ignore-not-found --wait=true
if [ -n "$(kubectl -n app get networkpolicy -o name)" ]; then
  echo "namespace app 에 NetworkPolicy 가 남아 있습니다 (다른 문제의 흔적). 여기서 멈추고 그 문제의 cleanup.sh 를 먼저 실행하세요."
  kubectl -n app get networkpolicy
fi

# 1) 백엔드: nginx 3개 + ClusterIP Service web(80) + NodePort Service web-np
kubectl -n app create deployment web --image=nginx:1.27 --replicas=3 --port=80
kubectl -n app expose deployment web --name=web --port=80 --target-port=80
kubectl -n app expose deployment web --name=web-np --type=NodePort --port=80 --target-port=80

# 2) 테스트용 파드 client 를 대상 노드에 미리 띄운다
#    (고장 난 뒤에는 CNI 에 따라 그 노드에 새 파드가 안 뜰 수 있다 — 풀이 참고)
cat <<YAML | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: client
  namespace: app
  labels: {run: client}
spec:
  nodeName: $NODE
  containers:
  - name: client
    image: busybox:1.36
    command: ["sleep", "86400"]
YAML
kubectl -n app rollout status deploy web --timeout=180s
kubectl -n app wait pod client --for=condition=Ready --timeout=120s

# 3) 고장 내기 1: 대상 노드를 뺀 모든 노드에 라벨을 달고 DaemonSet 에 그 라벨을 nodeSelector 로 넣는다
#    → 대상 노드의 kube-proxy 파드가 지워진다. kube-proxy 는 종료할 때 룰을 지우지 않으므로 아직은 동작한다
for n in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
  [ "$n" = "$NODE" ] || kubectl label node "$n" kube-proxy=enabled --overwrite >/dev/null
done
kubectl patch $DS --type=merge -p '{"spec":{"template":{"spec":{"nodeSelector":{"kube-proxy":"enabled"}}}}}'
kubectl rollout status $DS --timeout=300s
for _ in $(seq 40); do
  [ -z "$(kubectl -n kube-system get pods -l k8s-app=kube-proxy --field-selector spec.nodeName=$NODE -o name)" ] && break
  sleep 3
done

# 4) 고장 내기 2: 재부팅 흉내 — 대상 노드에서 kube-proxy --cleanup 을 한 번 돌려 Service 룰을 모두 지운다
#    (iptables · nftables · IPVS 모드 모두 지움. hostNetwork + privileged 파드라 ssh 없이 된다)
IMG=$(kubectl get $DS -o jsonpath='{.spec.template.spec.containers[0].image}')
BIN=$(kubectl get $DS -o jsonpath='{.spec.template.spec.containers[0].command[0]}')
BIN=${BIN:-/usr/local/bin/kube-proxy}
cat <<YAML | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: c17-reboot-sim
  namespace: kube-system
spec:
  nodeName: $NODE
  hostNetwork: true
  restartPolicy: Never
  tolerations: [{operator: Exists}]
  containers:
  - name: flush
    image: $IMG
    command: ["$BIN", "--cleanup"]
    securityContext: {privileged: true}
    volumeMounts:
    - {name: xtables-lock, mountPath: /run/xtables.lock}
    - {name: lib-modules, mountPath: /lib/modules, readOnly: true}
  volumes:
  - {name: xtables-lock, hostPath: {path: /run/xtables.lock, type: FileOrCreate}}
  - {name: lib-modules, hostPath: {path: /lib/modules}}
YAML
PHASE=""
for _ in $(seq 60); do
  PHASE=$(kubectl -n kube-system get pod c17-reboot-sim -o jsonpath='{.status.phase}')
  case "$PHASE" in Succeeded|Failed) break ;; esac
  sleep 3
done
kubectl -n kube-system logs c17-reboot-sim --tail=20 || true
[ "$PHASE" = "Succeeded" ] || echo "경고: 룰 정리 파드가 $PHASE 로 끝났습니다. 아래 확인 결과를 보세요."
kubectl -n kube-system delete pod c17-reboot-sim --ignore-not-found

# 5) 시작 상태 확인: 엔드포인트 3개, 파드IP 직접 접속은 되고 ClusterIP 는 멈춘다
kubectl -n app get deploy,svc,pod -o wide
kubectl -n app get endpointslice -l kubernetes.io/service-name=web
POD_IP=$(kubectl -n app get pod -l app=web -o jsonpath='{.items[0].status.podIP}')
CIP=$(kubectl -n app get svc web -o jsonpath='{.spec.clusterIP}')
kubectl -n app exec client -- wget -qO- -T 3 "http://$POD_IP" >/dev/null && echo "파드IP $POD_IP → 응답 있음"
kubectl -n app exec client -- wget -qO- -T 3 "http://$CIP" >/dev/null 2>&1 && echo "ClusterIP 가 아직 응답합니다 — 설정이 덜 됐습니다" || echo "ClusterIP $CIP → 응답 없음 (의도한 상태)"
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh              # 환경 만들기 (문제 노드: worker01)
bash cleanup.sh            # 실습 후 정리
bash setup.sh worker02     # 노드 이름이 다르면 인자로 준다 (cleanup.sh 도 같은 인자)
```

설정 직후 `app` 에는 Deployment `web`(nginx 3개), Service `web`(ClusterIP 80), Service `web-np`(NodePort)가 있고, `worker01` 에 테스트용 파드 `client`(busybox)가 떠 있다. `kubectl -n app exec client -- wget -qO- -T 3 http://<파드IP>` 는 응답하지만 ClusterIP 와 서비스 이름으로는 응답이 없다. 다른 노드의 파드에서는 정상이다.
busybox 에는 `curl` 이 없으므로 문제의 `curl` 은 `wget -qO- -T 3` 으로 바꿔 쓴다. kube-proxy DaemonSet 을 쓰는 클러스터가 필요하다(Cilium 의 kube-proxy 대체 모드에서는 재현되지 않는다). `app` 네임스페이스는 다른 문제도 쓰므로 setup·cleanup 은 이 문제가 만든 리소스만 지우고, 다른 문제의 NetworkPolicy 가 남아 있으면 멈춘다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

`worker01` 을 뺀 모든 노드에 `kube-proxy=enabled` 라벨을 달고 kube-proxy DaemonSet 에 `nodeSelector: kube-proxy=enabled` 를 넣어 `worker01` 의 kube-proxy 파드를 없앤다. 그다음 재부팅을 흉내 내려고 `worker01` 에 hostNetwork·privileged 파드(`kube-system/c17-reboot-sim`)를 한 번 띄워 `kube-proxy --cleanup` 으로 그 노드의 Service 룰(iptables·nftables·IPVS)을 지우고, 끝나면 그 파드도 지운다. `cleanup.sh` 는 DaemonSet 의 `kube-proxy` 셀렉터와 노드 라벨을 지우고, `worker01` 의 kube-proxy 가 다시 Ready 가 될 때까지 기다린다(시작하면서 룰을 전부 다시 쓴다).

</details>

<details><summary>정리 명령 (방법 A)</summary>

```bash
NODE=worker01
DS="-n kube-system ds/kube-proxy"

# 1) DaemonSet nodeSelector 원복 + 노드 라벨 제거 (풀 때 라벨 방식으로 고쳤어도 같이 지운다)
if kubectl get $DS -o jsonpath='{.spec.template.spec.nodeSelector}' | grep -q '"kube-proxy"'; then
  kubectl patch $DS --type=json -p='[{"op":"remove","path":"/spec/template/spec/nodeSelector/kube-proxy"}]'
fi
kubectl label nodes --all kube-proxy- >/dev/null 2>&1 || true
kubectl -n kube-system delete pod c17-reboot-sim --ignore-not-found
kubectl rollout status $DS --timeout=300s

# 2) 대상 노드에 kube-proxy 가 다시 Ready 인지 확인 (시작하면서 룰을 전부 다시 쓴다)
if kubectl get node "$NODE" >/dev/null 2>&1; then
  kubectl -n kube-system wait pod -l k8s-app=kube-proxy --field-selector spec.nodeName=$NODE \
    --for=condition=Ready --timeout=180s
fi
kubectl -n kube-system get ds kube-proxy

# 3) 이 문제가 만든 리소스만 정리
kubectl -n app delete deploy web --ignore-not-found
kubectl -n app delete svc web web-np --ignore-not-found
kubectl -n app delete pod client dbg v v2 --ignore-not-found
```

</details>

## Task

`worker01` was rebooted this morning after kernel maintenance. Since then, in namespace
`app`, Service `web` (ClusterIP, port 80) still has 3 healthy endpoints, and from a pod
**on `worker01`** `curl http://<pod-ip>:80` works for every backend pod, but
`curl http://web.app.svc.cluster.local` and `curl http://<cluster-ip>:80` both hang.
NodePort Service `web-np` is unreachable through `worker01`'s IP. Pods on other nodes are
not affected.

1. Show that neither CoreDNS nor the Service's endpoints are the cause — one command each.
2. Identify the component responsible for ClusterIP translation and check its state on
   `worker01`.
3. Inspect the node's NAT rules to show the Service chains are missing.
4. Find and fix the root cause. Do not recreate the Service.
5. Verify ClusterIP and NodePort both work again.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
