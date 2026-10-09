# q05 — Autoscale a Deployment with an HPA

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
# 1. metrics-server 확인 (없으면 설치)
kubectl -n kube-system get deploy metrics-server || {
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
  # kubeadm 실습 클러스터는 kubelet 인증서가 self-signed라 이 옵션이 필요
  kubectl -n kube-system patch deploy metrics-server --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
}
kubectl -n kube-system rollout status deploy metrics-server
kubectl top nodes          # 값이 나오면 준비 완료 (설치 직후 1분 정도 걸릴 수 있음)

# 2. namespace autoscale 생성
kubectl create namespace autoscale

# 3. Deployment apache-web 생성 (httpd:2.4, requests.cpu 100m)
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache-web
  namespace: autoscale
spec:
  replicas: 1
  selector:
    matchLabels:
      app: apache-web
  template:
    metadata:
      labels:
        app: apache-web
    spec:
      containers:
      - name: httpd
        image: httpd:2.4
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
YAML
kubectl -n autoscale rollout status deploy apache-web

# 4. 다시 풀 때: 이전에 만든 HPA 삭제
kubectl -n autoscale delete hpa apache-web --ignore-not-found
```

## Task

Deployment `apache-web` in namespace `autoscale` runs `httpd:2.4`, and its container already
requests `100m` CPU. metrics-server is installed.

1. Create a HorizontalPodAutoscaler named `apache-web` in namespace `autoscale` with API version
   `autoscaling/v2`. It targets Deployment `apache-web` with `minReplicas: 1`, `maxReplicas: 4`
   and a target average CPU utilization of `50%`.
2. When scaling down, the HPA must use a stabilization window of `30` seconds.
3. Confirm that the HPA reports an actual CPU percentage instead of `<unknown>`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
