# q14 — Pods stay Pending because the scheduler is broken

| Item | Value |
|---|---|
| Exam | mock_exam_d |
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

# 0) 이전 실습 흔적 정리: 보관해 둔 원본이 있으면 먼저 되돌린다 (A17·B16 등 다른 문제가 남긴 것 포함)
mkdir -p $KEEP
[ ! -f $KEEP/kube-scheduler.yaml ] || cp $KEEP/kube-scheduler.yaml $MAN/kube-scheduler.yaml
rm -rf /opt/course/d14
mkdir -p /opt/course/d14
kubectl delete pod sched-test --ignore-not-found || true

# 1) 원본 확인: kube-scheduler 와 kube-apiserver 의 이미지 태그가 같아야 정상
TAG=$(grep -m1 'image:' $MAN/kube-apiserver.yaml | sed 's/.*://')
echo "kube-apiserver 태그: $TAG"
cp $MAN/kube-scheduler.yaml $KEEP/kube-scheduler.yaml

# 2) 고장 내기: 태그 끝에 x 를 붙인다 (없는 태그 → ErrImagePull / ImagePullBackOff)
sed -i "s#kube-scheduler:$TAG\$#kube-scheduler:${TAG}x#" $MAN/kube-scheduler.yaml

# 3) 시작 상태 확인: 30초~1분 뒤 kube-scheduler-<노드이름> 이 ImagePullBackOff
grep 'image:' $MAN/kube-scheduler.yaml
sleep 30
kubectl -n kube-system get pods -l component=kube-scheduler
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

설정 후 30초~1분 뒤 `kube-scheduler-<노드이름>` 이 `ErrImagePull` / `ImagePullBackOff` 가 된다. 랩의 컨트롤 플레인 노드 이름이 `cp01` 이 아니면 파드 이름도 그 이름을 따른다. `/opt/course/d14/` 는 비어 있다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

kube-scheduler 이미지 태그 끝에 `x` 를 붙인다(예: `v1.35.0x`). 고장 내기 전에 원본을 `/root/.cka-setup/kube-scheduler.yaml` 에 보관하며, 풀이에서 만드는 `/opt/course/d14/kube-scheduler.yaml.bak` 과는 별개다. 원본의 태그가 kube-apiserver 와 다르면 원본이 아니라고 보고 멈춘다.
`cleanup.sh` 는 보관한 원본으로 되돌리고, 매니페스트 디렉터리 안에 남은 `kube-scheduler` 백업 파일(`.bak` 등)을 `/root/.cka-setup/` 로 옮기고, `sched-test` 파드를 지운 뒤 스케줄러가 다시 뜰 때까지 기다린다. B16 도 같은 파일을 쓰지만, 두 setup 모두 먼저 원본으로 되돌린 뒤 고장 내므로 어느 순서로 해도 안전하다.

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
rm -rf /opt/course/d14
kubectl delete pod sched-test --ignore-not-found || true

# 4) kube-scheduler 컨테이너가 다시 Running 이 될 때까지 기다린다 (최대 3분)
for _ in $(seq 60); do crictl ps --name kube-scheduler -q | grep -q . && break; sleep 3; done
crictl ps --name kube-scheduler
kubectl -n kube-system get pods -l component=kube-scheduler
```

</details>

## Task

Newly created pods stay `Pending` and show no events. `kubectl -n kube-system get pods` shows
`kube-scheduler-cp01` in `ImagePullBackOff`.

1. On `cp01`, find what is wrong in the kube-scheduler static pod manifest.
2. Before changing it, copy the manifest to `/opt/course/d14/kube-scheduler.yaml.bak` on `cp01`.
3. Fix the manifest so that kube-scheduler uses the same image tag as the kube-apiserver
   manifest.
4. Confirm that `kube-scheduler-cp01` is `Running` and that a new pod `sched-test`
   (image `nginx:1.27`, namespace `default`) gets scheduled to a node.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
