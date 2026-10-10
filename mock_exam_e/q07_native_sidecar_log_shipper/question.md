# q07 — Add a native sidecar to an existing Deployment

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
kubectl delete ns synergy --ignore-not-found --wait=true

# 1) namespace + Deployment synergy-app (컨테이너 app 하나, emptyDir logs 를 /var/log 에 마운트)
kubectl create ns synergy
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: synergy-app
  namespace: synergy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: synergy-app
  template:
    metadata:
      labels:
        app: synergy-app
    spec:
      containers:
      - name: app
        image: busybox:1.36
        command: ["sh", "-c", "while true; do echo \"$(date) processed\" >> /var/log/app.log; sleep 5; done"]
        volumeMounts:
        - name: logs
          mountPath: /var/log
      volumes:
      - name: logs
        emptyDir: {}
EOF

kubectl -n synergy rollout status deploy synergy-app

# 2) 설정 확인: 파드 1/1, initContainers 없음
kubectl -n synergy get pods
kubectl -n synergy get deploy synergy-app \
  -o jsonpath='{.spec.template.spec.containers[*].name}{" | init: "}{.spec.template.spec.initContainers}{"\n"}'
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 파드는 `1/1` 이고 `initContainers` 는 비어 있다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns synergy --ignore-not-found
```

</details>

## Task

Deployment `synergy-app` in namespace `synergy` has a single container `app` (`busybox:1.36`)
that appends a line to `/var/log/app.log` every few seconds. The file lives on the `emptyDir`
volume `logs`, which is mounted at `/var/log`.

1. Add a sidecar container named `sidecar` to the Deployment: image `busybox:1.36`, command
   `sh -c 'tail -n+1 -F /var/log/app.log'`, mounting volume `logs` at `/var/log`.
2. Define it as a **native sidecar**: an init container that keeps running for the whole life of
   the pod. Do not change container `app`.
3. Confirm that the new pod shows `2/2` ready and that the logs of container `sidecar` show the
   lines written by `app`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
