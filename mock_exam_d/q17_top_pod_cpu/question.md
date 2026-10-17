# q17 — Find the heaviest Pod with kubectl top

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Troubleshooting (30%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리
kubectl delete ns batch --ignore-not-found --wait=true
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
kubectl create ns batch
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
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `batch` 에는 `cruncher-1`(CPU 최대 100m), `cruncher-2`(CPU 최대 400m), `idle-0` 이 있다. metrics-server 가 첫 값을 모으기까지 1분 정도 걸릴 수 있다.
노드 메모리(2번)는 클러스터 상태 그대로 답한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns batch --ignore-not-found
rm -rf /opt/course/d17
```

</details>

## Task

metrics-server is running in the cluster. Several pods in namespace `batch` are busy.

1. Write the name of the pod in namespace `batch` that currently uses the most CPU to
   `/opt/course/d17/pod.txt` (the pod name only).
2. Write the name of the node that currently uses the most memory, in absolute terms (bytes,
   not percent), to `/opt/course/d17/node.txt` (the node name only).

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
