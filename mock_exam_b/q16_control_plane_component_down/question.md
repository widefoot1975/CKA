# q16 — A control plane component is not running

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh cp01`, then `sudo -i` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

이 문제는 **클러스터를 일부러 고장 낸 상태에서** 시작한다. `cp01` 에서 root 로 아래 둘 중 하나를 실행한다. 여러 번 실행해도 안전하다. 실습이 끝나면 반드시 정리(cleanup)해서 클러스터를 원래대로 돌려놓는다.

**방법 A — 명령어를 복사해서 붙여 넣기** (`ssh cp01` → `sudo -i` 한 뒤)

<details><summary>명령어 펼치기 — 고장 내는 내용이 보이니 풀기 전에는 읽지 않는 것을 권장</summary>

```bash
export KUBECONFIG=/etc/kubernetes/admin.conf
MAN=/etc/kubernetes/manifests
KEEP=/root/.cka-setup          # 원본 매니페스트 보관 위치 (반드시 매니페스트 디렉터리 밖)

# 0) 이전 실습 흔적 정리: 보관해 둔 원본이 있으면 먼저 되돌린다 (D14 등 다른 문제가 남긴 것 포함)
mkdir -p $KEEP
[ ! -f $KEEP/kube-scheduler.yaml ] || cp $KEEP/kube-scheduler.yaml $MAN/kube-scheduler.yaml
rm -rf /opt/q16
mkdir -p /opt/q16
kubectl delete pod sched-test --ignore-not-found || true

# 1) 원본 확인 후 보관: kubeadm 매니페스트의 "    image:" 줄(공백 4칸)이 한 줄 있어야 한다
cp $MAN/kube-scheduler.yaml $KEEP/kube-scheduler.yaml

# 2) 고장 내기: image: 줄의 들여쓰기를 4칸 → 3칸으로 (yaml 파싱 실패 → kubelet 이 파드를 아예 만들지 않음)
sed -i 's/^    image: /   image: /' $MAN/kube-scheduler.yaml

# 3) 시작 상태 확인: 1분쯤 뒤 kube-scheduler 파드가 kube-system 목록에서 사라진다 (kubelet 이 20초 주기로 디렉터리를 다시 읽음)
sleep 45
kubectl -n kube-system get pods -l component=kube-scheduler
echo "이제 새 파드를 만들면 Pending 에 머물고 이벤트도 없다"
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

설정 후 1분 안에 `kube-scheduler-<노드이름>` 이 `kubectl -n kube-system get pods` 목록에서 사라지고, 새 파드는 이벤트 없이 `Pending` 에 머문다. 기존 파드와 `kubectl` 은 그대로 동작한다. `/opt/q16/` 는 비어 있다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

`kube-scheduler.yaml` 의 `image:` 줄 들여쓰기를 4칸에서 3칸으로 바꿔 yaml 파싱을 깨뜨린다. kubelet 은 이 디렉터리를 20초쯤마다 다시 읽으며, 읽지 못한 파일의 정적 파드는 내린다.
고장 내기 전에 원본을 `/root/.cka-setup/kube-scheduler.yaml` 에 보관한다. `cleanup.sh` 는 원본으로 되돌리고, 매니페스트 디렉터리 안에 남은 `kube-scheduler` 백업 파일을 밖으로 옮기고, `sched-test` 파드를 지운 뒤 스케줄러가 다시 뜰 때까지 기다린다. D14 도 같은 파일을 쓰지만, 두 setup 모두 먼저 원본으로 되돌린 뒤 고장 내므로 어느 순서로 해도 안전하다.

</details>

<details><summary>정리 명령 (방법 A, cp01 에서 root 로)</summary>

```bash
export KUBECONFIG=/etc/kubernetes/admin.conf
MAN=/etc/kubernetes/manifests
KEEP=/root/.cka-setup
mkdir -p $KEEP

# 1) setup.sh 가 보관한 원본으로 되돌린다
if [ -f $KEEP/kube-scheduler.yaml ]; then
  cp $KEEP/kube-scheduler.yaml $MAN/kube-scheduler.yaml
  rm $KEEP/kube-scheduler.yaml
fi

# 2) 매니페스트 디렉터리 안에 남은 백업(.bak 등)은 kubelet 이 파드로 읽으므로 밖으로 옮긴다
for f in $MAN/*kube-scheduler*; do
  [ "$f" = $MAN/kube-scheduler.yaml ] || mv -v "$f" $KEEP/
done

# 3) 실습 산출물 정리
rm -rf /opt/q16
kubectl delete pod sched-test --ignore-not-found || true

# 4) kube-scheduler 컨테이너가 다시 Running 이 될 때까지 기다린다 (최대 3분)
for _ in $(seq 60); do crictl ps --name kube-scheduler -q | grep -q . && break; sleep 3; done
crictl ps --name kube-scheduler
kubectl -n kube-system get pods -l component=kube-scheduler
```

</details>

## Task

Newly created pods stay `Pending` forever with no scheduling events. Existing pods keep
running and `kubectl` works normally.

1. Identify which control plane component is failing and write its name to
   `/opt/q16/component.txt`.
2. On `cp01`, find the reason using the container runtime and the kubelet journal, since
   the component's pod does not appear in `kubectl get pods -n kube-system`. Write the
   decisive log line to `/opt/q16/log.txt`.
3. Repair the component. Do not delete anything under `/etc/kubernetes/pki`.
4. Confirm a new pod schedules and the component is `Running` and `1/1`.
5. Write to `/opt/q16/why.txt` where this component's manifest lives and why
   `kubectl delete pod` is not how you restart it.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
