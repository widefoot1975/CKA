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

## PreIns

```
# 1. namespace
kubectl create ns wp

# 2. Deployment wordpress (init 컨테이너 init-perms + 앱 컨테이너 wordpress, resources 없음)
#    init 컨테이너는 imperative로 못 만들어서 YAML로 작성
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

# 3. 시작 상태 확인: 파드 2개 Running, resources 비어 있음
kubectl -n wp rollout status deploy wordpress
kubectl -n wp get deploy wordpress -o jsonpath='{.spec.template.spec.initContainers[0].resources}{"\n"}{.spec.template.spec.containers[0].resources}{"\n"}'
```

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
