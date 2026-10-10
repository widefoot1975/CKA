# q06 — Set resources on every container, including init

| Item | Value |
|---|---|
| Exam | mock_exam_e |
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
# 0) 이전 실습 흔적 정리
kubectl delete ns wp --ignore-not-found --wait=true

# 1) namespace
kubectl create ns wp

# 2) Deployment wordpress (init 컨테이너 init-perms + 앱 컨테이너 wordpress, resources 없음)
#    init 컨테이너는 imperative 로 못 만들어서 YAML 로 작성
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  namespace: wp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      initContainers:
      - name: init-perms
        image: busybox:1.36
        command: ["sh", "-c", "chown -R 33:33 /var/www/html"]
        volumeMounts:
        - name: html
          mountPath: /var/www/html
      containers:
      - name: wordpress
        image: wordpress:6-apache
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /var/www/html
      volumes:
      - name: html
        emptyDir: {}
YAML

# 3) 시작 상태 확인: 파드 2개 Running, resources 비어 있음
kubectl -n wp rollout status deploy wordpress
kubectl -n wp get deploy wordpress \
  -o jsonpath='{.spec.template.spec.initContainers[0].resources}{"\n"}{.spec.template.spec.containers[0].resources}{"\n"}'
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 파드 2개가 Running 이고, 두 컨테이너의 resources 는 `{}` 로 비어 있다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns wp --ignore-not-found
```

</details>

## Task

Deployment `wordpress` in namespace `wp` has an init container `init-perms` and an app container
`wordpress`. Neither of them has resource requests or limits.

1. Scale Deployment `wordpress` to `0` replicas before you change it.
2. Set exactly these resources on **both** the init container `init-perms` and the container
   `wordpress`: requests `cpu: 250m`, `memory: 256Mi`; limits `cpu: 500m`, `memory: 512Mi`.
3. Scale the Deployment to `3` replicas. Confirm that all 3 pods are `Running` and ready, and that
   both containers in the pod template carry the new resources.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
