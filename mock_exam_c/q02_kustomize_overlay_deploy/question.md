# q02 — Deploy an environment overlay with Kustomize

| Item | Value |
|---|---|
| Exam | mock_exam_c |
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
kubectl delete ns prod-web --ignore-not-found --wait=true
rm -rf /opt/course/q02

# 1) base 및 overlays 디렉터리 구조 생성
mkdir -p /opt/course/q02/base
mkdir -p /opt/course/q02/overlays/prod

# 2) Deployment web (nginx:1.25, 1 replica, containerPort 80)
cat <<'EOF' > /opt/course/q02/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

# 3) Service web
cat <<'EOF' > /opt/course/q02/base/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
EOF

# 4) base kustomization.yaml
cat <<'EOF' > /opt/course/q02/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml
EOF

# 5) 설정 확인
find /opt/course/q02 | sort
kubectl kustomize /opt/course/q02/base > /dev/null && echo "base renders OK"
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/q02/base/` 에 파일 3개가 있고 `overlays/prod/` 는 비어 있다. namespace `prod-web` 은 아직 없다(문제에서 직접 만든다).

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns prod-web --ignore-not-found
rm -rf /opt/course/q02
```

</details>

## Task

A base manifest set exists at `/opt/course/q02/base/` containing `deployment.yaml`
(Deployment `web`, image `nginx:1.25`, 1 replica), `service.yaml` and
`kustomization.yaml`.

Build a production overlay at `/opt/course/q02/overlays/prod/` that, without editing
any file under `base/`:

1. References the base.
2. Deploys into namespace `prod-web` (create the namespace).
3. Prefixes every resource name with `prod-`.
4. Adds the label `env: prod` to every resource.
5. Sets the `web` Deployment to 4 replicas.
6. Changes the image to `nginx:1.27`.
7. Adds a ConfigMap generated from literals `TIER=prod` and `LOG_LEVEL=warn`,
   named `web-config`.
8. Patches the container port to `8080` using a patch with an explicit `target`.

Render the overlay to stdout to review it **before** applying, then apply it.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
