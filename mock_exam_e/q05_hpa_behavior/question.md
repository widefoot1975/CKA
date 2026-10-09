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
# 1. metrics-server 설치 (실습 클러스터는 --kubelet-insecure-tls 필요)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl -n kube-system patch deploy metrics-server --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl get pods -n kube-system -l k8s-app=metrics-server

# 2. namespace + Deployment apache-web (httpd:2.4, CPU request 100m)
kubectl create ns autoscale
kubectl -n autoscale create deploy apache-web --image=httpd:2.4
kubectl -n autoscale set resources deploy apache-web --requests=cpu=100m
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
