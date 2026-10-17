# q16 — Read and evaluate container output streams

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh <node running the pod>` for step 5 |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리 — namespace logs 는 d16 도 쓰므로 namespace 는 지우지 않고 Deployment multi 만 지운다
kubectl -n logs delete deploy multi --ignore-not-found --wait=true
kubectl -n logs wait --for=delete pod -l app=multi --timeout=90s 2>/dev/null || true

# 1) namespace (없으면 만든다) + Deployment multi
#    - app: 첫 실행은 FATAL(stderr) 을 남기고 exit 1 → 한 번 재시작한 뒤에는 30줄을 찍고 3초마다 INFO(stdout)/WARN(stderr) 를 남긴다
#           같은 줄을 공유 emptyDir 의 /var/log/app/out.log 에도 쓴다 (첫 실행 여부는 emptyDir 의 표식 파일로 구분)
#    - shipper: 일반 컨테이너(두 번째), out.log 를 tail 해서 "forwarded:" 를 붙여 다시 출력한다
kubectl create ns logs --dry-run=client -o yaml | kubectl apply -f -
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multi
  namespace: logs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: multi
  template:
    metadata:
      labels:
        app: multi
    spec:
      containers:
      - name: app
        image: busybox:1.36
        command:
        - sh
        - -c
        - |
          log() { echo "$(date -u +%FT%TZ) $1 $HOSTNAME $2" | tee -a /var/log/app/out.log; }
          if [ ! -f /state/started ]; then
            touch /state/started
            log INFO "app starting (first run)"
            log FATAL "config reload failed, exiting" >&2
            sleep 3
            exit 1
          fi
          log INFO "app restarted, warming up"
          for i in $(seq 1 30); do log INFO "warm-up line $i"; done
          i=0
          while true; do
            i=$((i+1))
            if [ $((i % 5)) -eq 0 ]; then log WARN "slow request id=$i" >&2
            else log INFO "request id=$i served"; fi
            sleep 3
          done
        volumeMounts:
        - name: applog
          mountPath: /var/log/app
        - name: state
          mountPath: /state
      - name: shipper
        image: busybox:1.36
        command: ["sh", "-c", "touch /var/log/app/out.log; tail -n 0 -F /var/log/app/out.log | while read -r l; do echo \"forwarded: $l\"; done"]
        volumeMounts:
        - name: applog
          mountPath: /var/log/app
      volumes:
      - name: applog
        emptyDir: {}
      - name: state
        emptyDir: {}
EOF

# 2) 파드 3개의 app 이 모두 한 번씩 재시작하고 Ready 가 될 때까지 기다린다
for i in $(seq 1 60); do
  N=$(kubectl -n logs get pod -l app=multi \
        -o jsonpath='{range .items[*]}{.status.containerStatuses[?(@.name=="app")].restartCount}{"\n"}{end}' 2>/dev/null \
      | awk '$1 >= 1' | wc -l)
  [ "$N" -ge 3 ] && break
  sleep 3
done
kubectl -n logs wait pod -l app=multi --for=condition=Ready --timeout=120s

# 3) 설정 확인: 파드 3개 모두 READY 2/2, RESTARTS 1 — 5단계에서 들어갈 노드는 NODE 열에서 고른다
kubectl -n logs get pod -l app=multi -o wide
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `multi` 의 파드 3개는 모두 `READY 2/2`, `RESTARTS 1` 이다. `app` 의 첫 인스턴스는 stderr 에 FATAL 을 남기고 exit 1 로 죽었고,
지금 인스턴스는 30줄을 찍은 뒤 3초마다 INFO(stdout)/WARN(stderr) 를 남긴다. 줄마다 파드 이름이 들어 있어 어느 파드의 출력인지 구분된다.
`shipper` 는 지금은 **일반 컨테이너**(두 번째)이고, `app` 이 공유 볼륨에 쓴 줄을 `forwarded:` 를 붙여 다시 출력한다.
5단계는 `get pod -o wide` 의 NODE 열에 나온 노드로 `ssh` 해서 푼다.

namespace `logs` 는 `mock_exam_d/q16` 도 쓴다. 이 setup/cleanup 은 Deployment `multi` 만 다루고,
cleanup 은 namespace 에 다른 리소스가 남아 있으면 namespace 를 지우지 않는다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n logs delete deploy multi --ignore-not-found --wait=true
# namespace logs 에 다른 실습(d16 의 order-api 등)이 없을 때만:
kubectl delete ns logs --ignore-not-found
```

</details>

## Task

Deployment `multi` in `logs` runs 3 replicas of containers `app` and `shipper`.

1. Print the output of `app` alone, then the output of both containers of one pod at once
   with each line tagged by container.
2. Print the last 20 lines of `app` with timestamps, then only the last 5 minutes of it.
3. Follow `app` live, and print the output of the previous instance of `app` after a restart.
4. Print the output for the whole Deployment, then for all three pods, and state in one line
   why those two are not the same.
5. On the node, locate the on-disk log file of one of these containers and read the same
   output with `crictl` instead of `kubectl`.
6. State in one line how `shipper` must be declared so that it starts before `app` and keeps
   running for the life of the pod.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
