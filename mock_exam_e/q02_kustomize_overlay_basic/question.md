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

## PreIns

```
# 1. base 및 overlays 디렉터리 구조 생성
mkdir -p /opt/course/e02/base
mkdir -p /opt/course/e02/overlays/staging

# 2. Deployment api 생성 (nginx:1.27, 1 replica)
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

# 3. Service api 생성
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

# 4. base kustomization.yaml 생성
cat <<'EOF' > /opt/course/e02/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml
EOF
```

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
