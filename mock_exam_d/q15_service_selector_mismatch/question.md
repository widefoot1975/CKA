# q15 — A Service with no endpoints

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리
kubectl delete ns store --ignore-not-found --wait=true

# 1) namespace + Deployment catalog (파드 라벨 app=catalog)
kubectl create ns store
kubectl -n store create deploy catalog --image=nginx:1.27 --replicas=2 --port=80
kubectl -n store rollout status deploy catalog

# 2) Service catalog — selector 철자가 틀렸다 (catalogue)
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: catalog
  namespace: store
spec:
  selector:
    app: catalogue
  ports:
  - port: 80
    targetPort: 80
EOF

# 3) 설정 확인: 파드 2개 Ready, EndpointSlice 의 ENDPOINTS 는 비어 있음
kubectl -n store get pods --show-labels
kubectl -n store get endpointslice -l kubernetes.io/service-name=catalog
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `store` 에는 Ready 인 `catalog` 파드 2개(라벨 `app=catalog`)와 Service `catalog` 가 있고, EndpointSlice 의 ENDPOINTS 는 비어 있다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns store --ignore-not-found
```

</details>

## Task

In namespace `store`, requests to Service `catalog` (port 80) fail. Deployment `catalog`
(2 replicas, image `nginx:1.27`) is running and its pods are `Ready`.

1. Show that the Service has no endpoints by looking at its EndpointSlice.
2. Find the reason by comparing the Service's selector with the labels of the `catalog` pods.
3. Fix the Service so that it selects the `catalog` pods. Do not change the Deployment or the
   pods.
4. Confirm that the EndpointSlice now lists 2 pod addresses.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
