# q15 — Pods stuck in ContainerCreating after a CNI failure

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh worker01`, then `sudo -i` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

이 문제는 **클러스터를 일부러 고장 낸 상태에서** 시작한다. `kubectl` 이 되고 `ssh worker01` 과 그 안의 `sudo` 가 되는 `k8s-c1` 에서 아래 둘 중 하나를 실행한다. 노드 쪽 작업은 스크립트가 `ssh worker01 'sudo bash -s'` 로 보낸다. 여러 번 실행해도 안전하다. 실습이 끝나면 반드시 정리(cleanup)해서 클러스터를 원래대로 돌려놓는다.

**방법 A — 명령어를 복사해서 붙여 넣기** (`ssh k8s-c1` 한 뒤)

<details><summary>명령어 펼치기 — 고장 내는 내용이 보이니 풀기 전에는 읽지 않는 것을 권장</summary>

```bash
NODE=${NODE:-worker01}

# 0) 이전 실습 흔적 정리 — CNI 가 정상일 때 지워야 파드 정리가 멈추지 않으므로 노드부터 되돌린다
ssh "$NODE" 'sudo bash -s' <<'EOF'
set -euo pipefail
KEEP=/root/.cka-setup/b15
if [ -f $KEEP/plugin ] && [ -f $KEEP/bin/"$(cat $KEEP/plugin)" ]; then
  P=$(cat $KEEP/plugin)
  [ -e /opt/cni/bin/$P ] || mv $KEEP/bin/$P /opt/cni/bin/$P
fi
rm -rf $KEEP /opt/q15
EOF
kubectl get ns apps >/dev/null 2>&1 || { kubectl create ns apps; kubectl label ns apps cka-setup=b15; }
kubectl -n apps delete deploy web --ignore-not-found --cascade=foreground --wait=true

# 1) 고장 내기: worker01 의 CNI 설정(/etc/cni/net.d)은 그대로 두고, 그 설정이 부르는 플러그인 바이너리만 밖으로 옮긴다
#    (설정이 있으니 노드는 Ready, sandbox 를 만들 때만 실패한다)
ssh "$NODE" 'sudo bash -s' <<'EOF'
set -euo pipefail
[ ! -f /etc/kubernetes/manifests/kube-apiserver.yaml ] || { echo "컨트롤 플레인 노드입니다. worker 노드를 NODE 로 지정하세요."; exit 1; }
KEEP=/root/.cka-setup/b15
CONF=$(ls /etc/cni/net.d/*.conflist /etc/cni/net.d/*.conf 2>/dev/null | sort | head -1 || true)
[ -n "$CONF" ] || { echo "/etc/cni/net.d 에 CNI 설정이 없습니다. CNI 를 먼저 설치하세요."; exit 1; }
P=$(grep -o '"type": *"[^"]*"' "$CONF" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
[ -x /opt/cni/bin/$P ] || { echo "/opt/cni/bin/$P 가 없습니다 ($CONF 의 첫 플러그인)."; exit 1; }
mkdir -p $KEEP/bin /opt/q15
echo "$P" > $KEEP/plugin
mv /opt/cni/bin/$P $KEEP/bin/$P
echo "$(hostname): $CONF 는 그대로, /opt/cni/bin/$P 를 $KEEP/bin/ 으로 옮김"
EOF

# 2) 문제의 Deployment: 4 replica 를 worker 노드에 고르게 나눈다 (worker 2대면 2개씩)
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: apps
  labels: {app: web, cka-setup: b15}
spec:
  replicas: 4
  selector:
    matchLabels: {app: web}
  template:
    metadata:
      labels: {app: web}
    spec:
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: DoNotSchedule
        nodeTaintsPolicy: Honor          # taint 가 있는 컨트롤 플레인 노드는 계산에서 뺀다
        labelSelector:
          matchLabels: {app: web}
      containers:
      - name: nginx
        image: nginx:1.27-alpine
        ports:
        - containerPort: 80
EOF

# 3) 시작 상태 확인: NODE 쪽 파드만 ContainerCreating 이고 IP 가 없다. 노드는 계속 Ready
sleep 30
kubectl get nodes
kubectl -n apps get pods -l app=web -o wide
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
# k8s-c1 에서
bash setup.sh       # 환경 만들기
bash cleanup.sh     # 실습 후 정리

# worker 이름이 worker01 이 아니면
NODE=<worker 이름> bash setup.sh
NODE=<worker 이름> bash cleanup.sh
```

설정 후 `apps/web` 파드 4개 중 `worker01` 에 뜬 것(worker 2대면 2개)은 `ContainerCreating` 에 머물고 IP 가 없다. `worker02` 쪽은 `Running` 이고, `worker01` 은 계속 `Ready` 다. `worker01` 의 `/opt/q15/` 는 비어 있다.
Calico·flannel·Cilium 어느 CNI 든 동작하도록 `/etc/cni/net.d` 의 첫 설정 파일이 부르는 플러그인을 골라 고장 낸다. namespace `apps` 는 A05·D02 도 쓰므로, 그 문제들의 정리를 이 문제 전에 해 두면 깔끔하다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

`worker01` 의 `/etc/cni/net.d` 에서 첫 설정 파일의 첫 `"type"`(예: `calico`, `flannel`, `cilium-cni`)을 읽어, 그 바이너리를 `/opt/cni/bin` 에서 `/root/.cka-setup/b15/bin/` 으로 옮긴다. 설정은 그대로라 노드는 `Ready` 로 남고, 새 sandbox 를 만들 때만 `failed to find plugin` 으로 실패한다. 그다음 `apps/web`(4 replica, worker 에 고르게 분산)을 만든다.
`cleanup.sh` 는 바이너리가 아직 없으면 보관본을 되돌리고(보관본도 없으면 그 노드의 CNI 파드를 재시작해 다시 설치하게 하고), `cka-setup=b15` 라벨이 붙은 `apps/web` 만 지운다. namespace `apps` 는 이 setup 이 만들었고 비었을 때만 지운다. 바이너리를 먼저 되돌리는 이유는, 플러그인이 없으면 파드를 지울 때 네트워크 정리(CNI DEL)가 실패해 파드가 `Terminating` 에 걸리기 때문이다.

</details>

<details><summary>정리 명령 (방법 A, k8s-c1 에서)</summary>

```bash
NODE=${NODE:-worker01}

# 1) 보관해 둔 플러그인 바이너리를 되돌린다 (이미 고쳤으면 그대로 둔다). 먼저 해야 파드 삭제가 멈추지 않는다
P=$(ssh "$NODE" 'sudo bash -s' <<'EOF'
set -euo pipefail
KEEP=/root/.cka-setup/b15
P=$(cat $KEEP/plugin 2>/dev/null || true)
if [ -n "$P" ] && [ ! -e /opt/cni/bin/$P ] && [ -f $KEEP/bin/$P ]; then
  mv $KEEP/bin/$P /opt/cni/bin/$P
fi
if [ -n "$P" ] && [ ! -x /opt/cni/bin/$P ]; then echo "$P"; fi   # 그래도 없으면 이름만 알린다
[ -n "$P" ] && [ ! -x /opt/cni/bin/$P ] || rm -rf $KEEP
rm -rf /opt/q15
EOF
)

# 2) 보관본도 없으면 그 노드의 CNI DaemonSet 파드를 다시 띄워 init container 가 바이너리를 다시 깔게 한다
if [ -n "$P" ]; then
  echo "/opt/cni/bin/$P 를 되돌리지 못해 $NODE 의 CNI 파드를 재시작합니다"
  for l in k8s-app=calico-node app=flannel k8s-app=cilium; do
    kubectl delete pod -A -l $l --field-selector spec.nodeName=$NODE --ignore-not-found
  done
  sleep 30
  ssh "$NODE" "sudo bash -c 'test -x /opt/cni/bin/$P && rm -rf /root/.cka-setup/b15'" || \
    echo "아직 /opt/cni/bin/$P 가 없습니다. $NODE 의 CNI 파드 상태를 확인하세요."
fi

# 3) 이 문제가 만든 것만 지운다 (apps 는 A05·D02 도 쓰므로 namespace 는 이 setup 이 만들었고 비었을 때만 지운다)
kubectl -n apps delete deploy -l cka-setup=b15 --ignore-not-found --cascade=foreground --wait=true
if [ "$(kubectl get ns apps -o jsonpath='{.metadata.labels.cka-setup}' 2>/dev/null)" = b15 ] && \
   ! kubectl -n apps get deploy,sts,ds,job,pod --no-headers 2>/dev/null | grep -q .; then
  kubectl delete ns apps
fi

ssh "$NODE" 'ls /opt/cni/bin/'
kubectl -n apps get pods 2>/dev/null || true
```

</details>

## Task

Every pod scheduled to `worker01` is stuck in `ContainerCreating`. Pods on `worker02`
start normally. `worker01` reports `Ready`. Deployment `apps/web` has 4 replicas and only
the ones on `worker02` have an IP.

1. Write the pod event that explains the failure to `/opt/q15/event.txt`.
2. From `worker01`, check the runtime and the CNI state. Write the path of the CNI
   configuration directory and what you found there to `/opt/q15/cni.txt`.
3. Identify the cause and write it to `/opt/q15/cause.txt`.
4. Repair it so every `apps/web` pod reaches `Running` with a pod IP.
5. Clean up any sandbox left behind by the failed attempts.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
