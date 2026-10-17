# q16 — Collect logs from every container of a Pod

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.
namespace `obs` 는 C15 도 쓰므로 namespace 는 지우지 않고 이 문제의 파드만 정리한다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리 (이 문제가 만드는 파드만)
kubectl -n obs delete pod pipeline --ignore-not-found --wait=true 2>/dev/null || true
rm -rf /opt/course/f16

# 1) namespace + Pod pipeline: init 컨테이너 migrate → 컨테이너 ingest, transform
#    namespace 는 없을 때만 만들고, 이 실습이 만들었다는 표시를 남긴다 (cleanup 이 이 표시를 보고 판단)
if ! kubectl get ns obs >/dev/null 2>&1; then
  kubectl create ns obs
  kubectl label ns obs cka-lab-f16=created --overwrite
fi
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: pipeline
  namespace: obs
spec:
  initContainers:
  - name: migrate
    image: busybox:1.36
    command: ["sh", "-c", "echo 'migrate: applying 001_init'; echo 'migrate: applying 002_orders'; echo 'migrate: done'"]
  containers:
  - name: ingest
    image: busybox:1.36
    command:
    - sh
    - -c
    - |
      i=0
      while true; do i=$((i+1)); echo "INFO ingest received record $i"; sleep 4; done
  - name: transform
    image: busybox:1.36
    command:
    - sh
    - -c
    - |
      i=0
      while true; do
        i=$((i+1))
        if [ $((i % 3)) -eq 0 ]; then echo "ERROR transform failed on record $i: bad schema"
        else echo "INFO transform ok record $i"; fi
        sleep 4
      done
EOF
kubectl -n obs wait pod pipeline --for=condition=Ready --timeout=120s

# 2) 답안 파일 디렉터리
mkdir -p /opt/course/f16

# 3) 설정 확인: READY 2/2 (init 컨테이너는 끝났으므로 세지 않음)
kubectl -n obs get pod pipeline
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `pipeline` 은 `READY 2/2` 다. `migrate` 는 세 줄을 찍고 끝났고, `ingest` 는 INFO 만, `transform` 은 세 줄에 한 번 ERROR 를 남긴다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n obs delete pod pipeline --ignore-not-found --wait=true 2>/dev/null || true
rm -rf /opt/course/f16

# namespace 는 이 실습의 setup 이 만들었고(라벨 cka-lab-f16=created) 남은 리소스가 없을 때만 지운다
for ns in obs; do
  [ "$(kubectl get ns "$ns" -o jsonpath='{.metadata.labels.cka-lab-f16}' 2>/dev/null || true)" = "created" ] || continue
  left=$( { kubectl -n "$ns" get all,configmap,secret,ingress,pvc,networkpolicy -o name 2>/dev/null
            kubectl -n "$ns" get gateway,httproute -o name 2>/dev/null; } \
          | grep -v '^configmap/kube-root-ca.crt$' || true)
  if [ -z "$left" ]; then
    kubectl delete ns "$ns"
  else
    echo "namespace $ns 에 다른 리소스가 남아 있어 namespace 는 지우지 않음:"
    echo "$left"
  fi
done
```

</details>

## Task

In namespace `obs`, Pod `pipeline` has one init container `migrate` and two containers
`ingest` and `transform`. The Pod is `Running`.

1. Write the names of all containers of Pod `pipeline` to `/opt/course/f16/containers.txt`,
   one per line: init containers first, then the regular containers, each in spec order.
2. Write the logs of all containers of `pipeline`, including the init container, to
   `/opt/course/f16/all.log`, with every line prefixed by the container it came from.
3. Write only the lines containing `ERROR` that container `transform` logged in the last
   15 minutes, with timestamps, to `/opt/course/f16/transform-errors.log`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
