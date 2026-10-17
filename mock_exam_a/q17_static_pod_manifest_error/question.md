# q17 — Control plane down from a static pod manifest error

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Troubleshooting (30%) |
| Points | 5 |
| Host | `ssh k8s-c1` → `ssh cp01`, then `sudo -i` (kubectl will not answer) |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

이 문제는 **클러스터를 일부러 고장 낸 상태에서** 시작한다. `cp01` 에서 root 로 아래 둘 중 하나를 실행한다. 여러 번 실행해도 안전하다. 실습이 끝나면 반드시 정리(cleanup)해서 클러스터를 원래대로 돌려놓는다.

**방법 A — 명령어를 복사해서 붙여 넣기** (`ssh cp01` → `sudo -i` 한 뒤)

<details><summary>명령어 펼치기 — 고장 내는 내용이 보이니 풀기 전에는 읽지 않는 것을 권장</summary>

```bash
MAN=/etc/kubernetes/manifests
KEEP=/root/.cka-setup          # 원본 매니페스트 보관 위치 (반드시 매니페스트 디렉터리 밖)

# 0) 이전 실습 흔적 정리: 보관해 둔 원본이 있으면 먼저 되돌린다 (E13 등 다른 문제가 남긴 것 포함)
mkdir -p $KEEP
[ ! -f $KEEP/kube-apiserver.yaml ] || cp $KEEP/kube-apiserver.yaml $MAN/kube-apiserver.yaml

# 1) 원본 확인 후 보관
cp $MAN/kube-apiserver.yaml $KEEP/kube-apiserver.yaml

# 2) 고장 내기 ("동료의 수정"): 플래그 이름에 s 를 하나 더 붙인다 → kube-apiserver 가 시작하자마자 종료
sed -i 's#- --authorization-mode=#- --authorization-modes=#' $MAN/kube-apiserver.yaml

# 3) 시작 상태 확인: 1분쯤 뒤 kubectl 은 connection refused, crictl ps -a 에 Exited kube-apiserver
grep -n -- '--authorization-mode' $MAN/kube-apiserver.yaml
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
# k8s-c1 에서 (스크립트를 cp01 로 보내 root 로 실행)
ssh cp01 'sudo bash -s' < setup.sh      # 환경 만들기
ssh cp01 'sudo bash -s' < cleanup.sh    # 실습 후 정리

# 스크립트를 cp01 에 복사해 두었다면
sudo bash setup.sh
sudo bash cleanup.sh
```

**실행하면 이 클러스터의 `kubectl` 이 전부 멈춘다.** 문제를 풀거나 `cleanup.sh` 를 돌려야 돌아온다.
설정 후 1분쯤 지나면 `kubectl` 이 포트 6443 에 대해 `connection refused` 로 실패한다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

kube-apiserver 매니페스트의 플래그 `--authorization-mode` 를 `--authorization-modes` 로 바꾼다("동료의 수정"). 컨테이너는 시작하자마자 종료되고 kubelet 이 계속 다시 띄운다.
고장 내기 전에 원본을 `/root/.cka-setup/kube-apiserver.yaml` 에 보관한다. `cleanup.sh` 는 원본으로 되돌리고, 매니페스트 디렉터리 안에 남은 `kube-apiserver` 백업 파일을 밖으로 옮긴 뒤 API 서버가 다시 응답할 때까지 기다린다. E13 도 같은 파일을 쓰지만, 두 setup 모두 먼저 원본으로 되돌린 뒤 고장 내므로 어느 순서로 해도 안전하다.

</details>

<details><summary>정리 명령 (방법 A, cp01 에서 root 로)</summary>

```bash
export KUBECONFIG=/etc/kubernetes/admin.conf
MAN=/etc/kubernetes/manifests
KEEP=/root/.cka-setup
mkdir -p $KEEP

# 1) setup.sh 가 보관한 원본으로 되돌린다
if [ -f $KEEP/kube-apiserver.yaml ]; then
  cp $KEEP/kube-apiserver.yaml $MAN/kube-apiserver.yaml
  rm $KEEP/kube-apiserver.yaml
fi

# 2) 매니페스트 디렉터리 안에 남은 백업(.bak 등)은 kubelet 이 파드로 읽으므로 밖으로 옮긴다
for f in $MAN/*kube-apiserver*; do
  [ "$f" = $MAN/kube-apiserver.yaml ] || mv -v "$f" $KEEP/
done

# 3) API 서버가 다시 응답할 때까지 기다린다 (최대 3분)
for _ in $(seq 60); do kubectl get --raw /healthz >/dev/null 2>&1 && break; sleep 3; done
kubectl get --raw /healthz; echo
kubectl get nodes
```

</details>

## Task

Every `kubectl` command on `cp01` fails with `connection refused` on port 6443. A colleague
edited a control plane manifest shortly before.

1. Confirm the API server is not listening and that this is not a kubeconfig problem.
2. Without using `kubectl`, list the control plane containers and identify which one is not
   running.
3. Read that container's output and quote the exact error.
4. Back the manifest up, then repair it so the API server comes back. Do not run
   `kubectl apply` and do not restart the kubelet.
5. Confirm the API server answers and all four control plane static pods are running, and
   state in one line the mechanism that restarted the pod.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
