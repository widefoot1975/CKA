# q02 — Apply a Kustomize overlay

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리
kubectl delete ns staging --ignore-not-found --wait=true
rm -rf /opt/course/e02

# 1) base 및 overlays 디렉터리 구조 생성
mkdir -p /opt/course/e02/base
mkdir -p /opt/course/e02/overlays/staging

# 2) Deployment api (nginx:1.27, 1 replica)
cat <<'EOF' > /opt/course/e02/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports:
        - containerPort: 80
EOF

# 3) Service api
cat <<'EOF' > /opt/course/e02/base/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: api
spec:
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 80
EOF

# 4) base kustomization.yaml
cat <<'EOF' > /opt/course/e02/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml
EOF

# 5) 설정 확인
find /opt/course/e02 | sort
kubectl kustomize /opt/course/e02/base > /dev/null && echo "base renders OK"
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/e02/base/` 에 파일 3개가 있고 `overlays/staging/` 은 비어 있다. namespace `staging` 은 아직 없다(문제에서 직접 만든다).

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns staging --ignore-not-found
rm -rf /opt/course/e02
```

</details>

## Task

A Kustomize base for the application `api` exists in `/opt/course/e02/base/`: Deployment `api`
(image `nginx:1.27`, 1 replica), Service `api` and a `kustomization.yaml`. Do not modify any file
under `base/`.

1. Create `/opt/course/e02/overlays/staging/kustomization.yaml` that uses the base and
   - places all resources in namespace `staging`,
   - sets Deployment `api` to `2` replicas,
   - changes the image `nginx` to `nginx:1.28`,
   - adds the label `env: staging` to all resources **without** changing any selector.
2. Create namespace `staging` and render the overlay with `kubectl kustomize` to check it.
3. Apply the overlay with `kubectl apply -k` and confirm that Deployment `api` in `staging` has
   2 ready replicas running `nginx:1.28`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
