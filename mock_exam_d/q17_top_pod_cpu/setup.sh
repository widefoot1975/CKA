#!/usr/bin/env bash
# d17 — Find the heaviest Pod with kubectl top · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# namespace batch 는 mock_exam_c/q07 도 쓰므로 namespace 는 지우지 않고 이 문제의 파드만 정리한다.
set -euo pipefail

# 0) 이전 실습 흔적 정리 (이 문제가 만드는 파드만)
kubectl -n batch delete pod cruncher-1 cruncher-2 idle-0 --ignore-not-found --wait=true 2>/dev/null || true
rm -rf /opt/course/d17

# 1) metrics-server 설치 (실습 클러스터는 --kubelet-insecure-tls 필요)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
if ! kubectl -n kube-system get deploy metrics-server \
     -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
  kubectl -n kube-system patch deploy metrics-server --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl -n kube-system rollout status deploy metrics-server --timeout=180s

# 2) namespace + 파드 세 개: CPU 를 태우는 cruncher-1(최대 100m)·cruncher-2(최대 400m), 노는 idle-0
#    busy loop 에 CPU limit 을 걸어 두어 순위가 매번 같게 나온다
#    namespace 는 없을 때만 만들고, 이 실습이 만들었다는 표시를 남긴다 (cleanup 이 이 표시를 보고 판단)
if ! kubectl get ns batch >/dev/null 2>&1; then
  kubectl create ns batch
  kubectl label ns batch cka-lab-d17=created --overwrite
fi
for spec in cruncher-1:100m cruncher-2:400m; do
  name=${spec%%:*}; cpu=${spec##*:}
  kubectl -n batch run "$name" --image=busybox:1.36 --labels=app=cruncher \
    --overrides="{\"spec\":{\"containers\":[{\"name\":\"$name\",\"image\":\"busybox:1.36\",\"command\":[\"sh\",\"-c\",\"while true; do :; done\"],\"resources\":{\"requests\":{\"cpu\":\"50m\"},\"limits\":{\"cpu\":\"$cpu\"}}}]}}"
done
kubectl -n batch run idle-0 --image=busybox:1.36 --labels=app=idle -- sleep 86400
kubectl -n batch wait pod --all --for=condition=Ready --timeout=120s

# 3) 답안 파일 디렉터리
mkdir -p /opt/course/d17

# 4) 첫 수집까지 기다렸다가 확인 (1분 정도 걸릴 수 있음)
for i in $(seq 1 30); do
  kubectl top pod -n batch >/dev/null 2>&1 && break
  sleep 5
done
kubectl top pod -n batch
