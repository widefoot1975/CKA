# q05 — Configure workload autoscaling with an HPA

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리 (이 문제가 만드는 오브젝트만)
kubectl -n web delete hpa frontend-hpa --ignore-not-found 2>/dev/null || true
kubectl -n web delete deploy frontend --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
rm -rf /opt/q05

# 1) metrics-server 설치 (실습 클러스터는 --kubelet-insecure-tls 필요)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
if ! kubectl -n kube-system get deploy metrics-server \
     -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
  kubectl -n kube-system patch deploy metrics-server --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl -n kube-system rollout status deploy metrics-server --timeout=180s

# 2) namespace — 없을 때만 만들고, 이 실습이 만들었다는 표시를 남긴다 (cleanup 이 이 표시를 보고 판단)
if ! kubectl get ns web >/dev/null 2>&1; then
  kubectl create ns web
  kubectl label ns web cka-lab-b05=created --overwrite
fi
#    Deployment frontend (nginx:1.27, 1 replica, resources 없음 → 컨테이너 이름 nginx)
kubectl -n web create deploy frontend --image=nginx:1.27 --replicas=1
kubectl -n web rollout status deploy frontend

# 3) 답안 파일 디렉터리
mkdir -p /opt/q05

# 4) 설정 확인: resources 가 비어 있고 HPA 는 없음
kubectl -n web get deploy frontend \
  -o jsonpath='{.spec.template.spec.containers[0].name}{" resources="}{.spec.template.spec.containers[0].resources}{"\n"}'
kubectl -n web get hpa
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `frontend` 의 컨테이너 이름은 `nginx`, resources 는 `{}` 이고 HPA 는 없다. metrics-server 가 값을 모으기까지 1분 정도 걸릴 수 있다.
namespace `web` 은 A06·A09·D08·F06 도 쓰므로 setup·cleanup 은 이 문제의 오브젝트(`frontend`, `frontend-hpa`)만 지우고, namespace 는 이 setup 이 만들었고 비어 있을 때만 지운다.
`mock_exam_d/q08` 도 `web` 에 Deployment `frontend` 를 만들므로 두 문제를 동시에 펼쳐 두지 않는다. `cleanup.sh` 는 metrics-server 를 남겨 둔다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n web delete hpa frontend-hpa --ignore-not-found 2>/dev/null || true
kubectl -n web delete deploy frontend --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
rm -rf /opt/q05
# metrics-server 는 다른 문제(kubectl top 등)에서도 쓰므로 남겨 둔다

# namespace 는 이 실습의 setup 이 만들었고(라벨 cka-lab-b05=created) 남은 리소스가 없을 때만 지운다
for ns in web; do
  [ "$(kubectl get ns "$ns" -o jsonpath='{.metadata.labels.cka-lab-b05}' 2>/dev/null || true)" = "created" ] || continue
  left=$( { kubectl -n "$ns" get all,configmap,secret,ingress,pvc,networkpolicy -o name 2>/dev/null
            kubectl -n "$ns" get gateway,httproute -o name 2>/dev/null; } \
          | grep -v '^configmap/kube-root-ca.crt$' || true)
  if [ -z "$left" ]; then
    kubectl delete ns "$ns"
  else
    echo "namespace $ns 에 다른 리소스가 남아 있어 namespace 는 지우지 않음:"
    echo "$left"
  fi
done
```

</details>

## Task

Namespace `web` contains deployment `frontend` (image `nginx:1.27`, 1 replica) with no
resource fields set. Its owner reports that an HPA they created shows `<unknown>` for CPU.

1. Give the `frontend` container a CPU request of `100m` and a CPU limit of `200m`,
   without editing a manifest file on disk.
2. Create a HorizontalPodAutoscaler named `frontend-hpa` in `web` using
   `autoscaling/v2`, targeting the `frontend` deployment, `minReplicas: 2`,
   `maxReplicas: 8`, scaling on average CPU **utilization** of `60%`. When scaling down,
   it must use a stabilization window of `30` seconds.
3. Confirm the HPA reports a real percentage in the `TARGETS` column rather than
   `<unknown>`, and that replicas settled at 2.
4. Write to `/opt/q05/answer.txt` the two prerequisites that must hold before an
   `averageUtilization` metric can be computed at all.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
