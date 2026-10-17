# q16 — Pods evicted under node disk pressure

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh worker02`, then `sudo -i` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

이 문제는 **노드 디스크를 일부러 채운 상태에서** 시작한다. `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다. 실습이 끝나면 반드시 정리(cleanup)해서 공간과 설정을 원래대로 돌려놓는다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기** (트러블슈팅 문제라 명령어에 답이 보인다. 미리 보고 싶지 않으면 방법 B 를 쓴다)

<details><summary>설정 명령 펼치기 (답 포함)</summary>

```bash
NODE=${NODE:-worker02}
NS=diskload
kubectl get node "$NODE" >/dev/null
ssh "$NODE" true

# 0) 이전 실습 흔적 정리: 원본 kubelet 설정 복구, 채운 파일 삭제, namespace 삭제
ssh "$NODE" sudo bash -s <<'REMOTE'
set -euo pipefail
CFG=/var/lib/kubelet/config.yaml
rm -rf /var/lib/c16-dump
if [ -f "$CFG.c16.orig" ]; then cp -p "$CFG.c16.orig" "$CFG"; systemctl restart kubelet; fi
REMOTE
kubectl delete ns "$NS" --ignore-not-found --wait=true
kubectl wait node "$NODE" --for=condition=Ready --timeout=120s
kubectl wait node "$NODE" --for=condition=DiskPressure=false --timeout=360s   # 재실행이면 최대 5분

# 1) worker02 에 고정된 Deployment — 축출될 파드들
kubectl create ns "$NS"
cat <<YAML | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: report-gen
  namespace: $NS
spec:
  replicas: 3
  selector:
    matchLabels:
      app: report-gen
  template:
    metadata:
      labels:
        app: report-gen
    spec:
      nodeSelector:
        kubernetes.io/hostname: $NODE
      containers:
      - name: gen
        image: busybox:1.36
        command: ["sh", "-c", "while true; do date; sleep 30; done"]
YAML
kubectl -n "$NS" rollout status deploy report-gen --timeout=180s

# 2) worker02 에서: 원본 설정을 보관하고, 큰 파일로 디스크를 채운 뒤
#    "채운 파일을 지우면 풀리는" 지점에 nodefs.available 임계값을 둔다
ssh "$NODE" sudo bash -s <<'REMOTE'
set -euo pipefail
CFG=/var/lib/kubelet/config.yaml
[ -f "$CFG.c16.orig" ] || cp -p "$CFG" "$CFG.c16.orig"

# kubelet 의 nodefs(/var/lib/kubelet)와 같은 파일시스템에 채워야 시그널이 움직인다
mkdir -p /var/lib/c16-dump
if [ "$(stat -c %d /var/lib/c16-dump)" != "$(stat -c %d /var/lib/kubelet)" ]; then
  echo "/var/lib/c16-dump 와 /var/lib/kubelet 이 다른 파일시스템입니다. 중단합니다."; rm -rf /var/lib/c16-dump; exit 1
fi

AVAIL=$(df -BM --output=avail /var/lib/kubelet | tail -1 | tr -dc '0-9')   # 지금 남은 공간(MiB)
[ "$AVAIL" -ge 1024 ] || { echo "남은 공간이 1GiB 미만이라 실습을 만들지 않습니다."; rm -rf /var/lib/c16-dump; exit 1; }
FILL=$(( AVAIL * 40 / 100 )); [ "$FILL" -le 2048 ] || FILL=2048           # 남은 공간의 40%, 최대 2GiB
THRESH=$(( AVAIL - FILL / 2 ))                                               # 채운 뒤 < THRESH < 지운 뒤

fallocate -l "${FILL}M" /var/lib/c16-dump/core.img 2>/dev/null \
  || dd if=/dev/zero of=/var/lib/c16-dump/core.img bs=1M count="$FILL" status=none
sync

# evictionHard 는 일부만 적으면 나머지 시그널이 0 이 되므로 기본값을 모두 같이 적는다
awk '/^evictionHard:/{skip=1; next} skip && /^[[:space:]]/{next} {skip=0; print}' \
  "$CFG.c16.orig" > "$CFG"
cat >> "$CFG" <<CONF
evictionHard:
  memory.available: "100Mi"
  nodefs.available: "${THRESH}Mi"
  nodefs.inodesFree: "5%"
  imagefs.available: "15%"
  imagefs.inodesFree: "5%"
CONF
systemctl restart kubelet
REMOTE

# 3) 시작 상태 확인: DiskPressure=True 가 되고 파드가 축출될 때까지 최대 3분 기다린다
for i in $(seq 1 36); do
  dp=$(kubectl get node "$NODE" -o jsonpath='{.status.conditions[?(@.type=="DiskPressure")].status}')
  ev=$(kubectl -n "$NS" get pods --field-selector=status.phase=Failed --no-headers 2>/dev/null | wc -l)
  [ "$dp" = "True" ] && [ "$ev" -gt 0 ] && break
  sleep 5
done
kubectl get node "$NODE"
kubectl -n "$NS" get pods -o wide
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

`k8s-c1` 에서 실행하지만 실제 변경은 `ssh worker02` 로 노드에서 한다. 그래서 `k8s-c1` → `worker02` ssh 와 `worker02` 의 암호 없는 `sudo` 가 필요하다. 이미지 `busybox:1.36` 을 받을 수 있어야 하고, `worker02` 의 `/var/lib/kubelet` 파일시스템에 1GiB 이상 남아 있어야 한다.
설정이 끝나면(최대 3분 기다린다) `worker02` 는 `Ready` 그대로지만 `DiskPressure=True` 이고, namespace `diskload` 의 파드 일부가 `Evicted`, 새로 생긴 파드는 `Pending` 이다. **`worker02` 에 떠 있던 다른 실습의 일반 파드도 함께 축출될 수 있다.**
`worker02` 에서 채운 크기는 남은 공간의 40%(최대 2GiB)라 디스크가 꽉 차지는 않는다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

`worker02` 의 `/var/lib/kubelet/config.yaml` 을 처음 실행할 때 `config.yaml.c16.orig` 로 보관한다. 그다음 `/var/lib/c16-dump/core.img` 로 디스크를 채우고, `evictionHard` 의 `nodefs.available` 을 "채운 뒤 남은 공간보다 크고, 그 파일을 지우면 남는 공간보다 작은" 값(MiB)으로 정해 kubelet 을 재시작한다. 그래서 큰 파일을 찾아 지우면 컨디션이 풀린다.
`cleanup.sh` 는 그 파일을 지워 공간을 돌려주고, 보관한 원본 설정으로 되돌린 뒤 kubelet 을 재시작하고 namespace `diskload` 를 지운다. 문제를 제대로 풀었어도 임계값과 보관 파일을 되돌리려면 꼭 실행한다.

</details>

<details><summary>정리 명령 (방법 A)</summary>

```bash
NODE=${NODE:-worker02}
ssh "$NODE" sudo bash -s <<'REMOTE'
set -euo pipefail
CFG=/var/lib/kubelet/config.yaml
rm -rf /var/lib/c16-dump
if [ -f "$CFG.c16.orig" ]; then cp -p "$CFG.c16.orig" "$CFG"; rm -f "$CFG.c16.orig"; fi
systemctl restart kubelet
df -h /var/lib/kubelet
REMOTE
kubectl delete ns diskload --ignore-not-found
kubectl wait node "$NODE" --for=condition=Ready --timeout=120s
# DiskPressure 는 kubelet 재시작 직후 False 로 돌아온다 (최대 5분 걸릴 수 있다)
kubectl wait node "$NODE" --for=condition=DiskPressure=false --timeout=360s
# 이 실습 때문에 다른 namespace 에서 축출된 파드가 있으면 보여 준다 (지우지는 않는다)
kubectl get pods -A --field-selector=status.phase=Failed -o wide | grep -E "NAME|Evicted" || true
```

</details>

## Task

Pods on `worker02` are disappearing. Several show status `Evicted`, and new pods stay
`Pending` with no node chosen. Other nodes are unaffected.

1. Show the node condition that explains this and the message the kubelet attached to it.
2. Report the kubelet eviction thresholds in effect on `worker02` and which filesystem
   signal crossed its threshold.
3. Find what is consuming the disk, distinguishing container images from container logs
   from other data.
4. Reclaim space so the condition clears. Remove unused images through the container
   runtime, not by deleting files under `/var/lib/containerd` by hand.
5. Confirm the node accepts pods again, and clean up the `Evicted` pod objects.
6. Note the difference between an evicted pod and an OOMKilled container in one line.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
