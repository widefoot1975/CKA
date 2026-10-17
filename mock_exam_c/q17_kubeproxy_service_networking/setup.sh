#!/usr/bin/env bash
# c17 — Service traffic broken by kube-proxy · 사전 환경 설정
#       (kube-proxy DaemonSet 이 대상 노드를 건너뛰게 만들고, 재부팅처럼 그 노드의 Service 룰을 지운다)
# 실행: bash setup.sh [노드이름]   (k8s-c1 에서 실행, 기본 노드는 worker01, 여러 번 실행해도 안전)
# 필요: kube-proxy DaemonSet 이 있는 클러스터 (Cilium 의 kube-proxy 대체 모드 등에서는 재현되지 않음)
set -euo pipefail
NODE=${1:-worker01}
DS="-n kube-system ds/kube-proxy"

kubectl get node "$NODE" >/dev/null 2>&1 || { echo "노드 $NODE 이 없습니다. bash setup.sh <워커노드이름> 으로 실행하세요."; kubectl get nodes; exit 1; }
kubectl get $DS >/dev/null 2>&1 || { echo "kube-system 에 kube-proxy DaemonSet 이 없습니다. 이 클러스터에서는 재현할 수 없습니다."; exit 1; }

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
  echo "namespace app 에 NetworkPolicy 가 남아 있습니다 (다른 문제의 흔적). 그 문제의 cleanup.sh 를 먼저 실행하세요."
  kubectl -n app get networkpolicy
  exit 1
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
