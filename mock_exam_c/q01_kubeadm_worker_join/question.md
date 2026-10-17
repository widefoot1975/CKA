# q01 — Join a new worker node to the cluster

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 7 |
| Host | `ssh k8s-c1` → `ssh cp01` and `ssh worker03`, then `sudo -i` |
| Target time | 7 min |

## Setup — 사전 환경 설정

이 문제는 **아직 클러스터에 들어가지 않은 머신**이 있어야 연습할 수 있다. 실습 클러스터에 남는 머신이 없으면
이미 join 된 워커 하나를 빼서 그 상태를 만든다. `cp01` 에서 노드를 drain 하고 Node 오브젝트를 지운 뒤,
워커에서 `kubeadm reset` 을 하면 `kubeadm`·`kubelet`·`containerd` 는 설치된 채 클러스터 설정만 사라진다.
여기에 노드 전제조건(swap, `br_netfilter`, `ip_forward`, `SystemdCgroup`)을 일부러 틀어 두면 문제의 시작 상태가 된다.

두 노드에서 차례로 root(`sudo -i`)로 실행한다. 여러 번 실행해도 안전하다. 워커 이름이 `worker03` 이 아니면
(예: `worker02`) 두 단계 모두 `sudo NODE=worker02 bash setup.sh prepare` 처럼 `NODE` 를 앞에 붙인다.
문제의 `worker03` 도 그 이름으로 읽는다. drain 은 `--force` 로 하므로 컨트롤러 없는 파드는 지워진다.
처음 실행할 때 워커의 원본 설정(`/etc/fstab`, `/etc/containerd/config.toml`, sysctl·모듈 설정)을
`/root/c01-backup` 에, 원래 노드 라벨을 `cp01` 의 `/root/c01-node-labels` 에 보관한다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_c/q01_kubeadm_worker_join
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
sudo bash setup.sh prepare    # cp01 에서 — 라벨 보관, drain, Node 삭제
sudo bash setup.sh fail       # worker03 에서 — yes 를 입력하면 reset 하고 전제조건을 틀어 둔다
sudo bash cleanup.sh worker   # worker03 에서 — 실습 후, 원본 설정 복원 (먼저)
sudo bash cleanup.sh cp       # cp01 에서 — 그다음, 테스트 파드 삭제·라벨 원복 (join 전이면 join 명령을 만들어 준다)
```

설정 직후 `cp01` 의 `kubectl get nodes` 에는 `worker03` 이 없고, `worker03` 에는 `/etc/kubernetes/kubelet.conf` 가
없다. kubelet 은 설정 파일이 없어 멈춰 있거나 재시작을 반복하는데, join 전에는 정상이다.
`kubeadm token list` 는 비어 있거나 기존 토큰만 보일 수 있다. 만료된 토큰은 컨트롤러 매니저의 tokencleaner 가
곧 지우므로, 목록에 남아 있지 않아도 문제의 전제("기존 토큰은 쓰지 않는다")와 다르지 않다.
`SystemdCgroup` 줄이 아예 없는 containerd 설정이면 ④ 는 바뀌지 않는다. 그 경우 풀이 1) 의 `containerd config default`
단계가 바로 연습 대상이다.
문제를 끝까지 풀었어도 **`cleanup.sh worker` → `cleanup.sh cp` 순서로 실행**한다. 보관한 원본 설정과 원래 라벨로
되돌리고 setup 이 만든 스왑 파일을 지운다. 중간에 그만뒀다면 `cleanup.sh cp` 가 다시 join 할 명령을 출력한다.

## Task

A freshly provisioned machine `worker03` has `kubeadm`, `kubelet` and `containerd`
installed but has never joined a cluster. Bring it into the cluster as a worker.

1. On `worker03`, confirm the node prerequisites are met: swap disabled, the
   `br_netfilter` module loaded, `net.ipv4.ip_forward` set to `1`, and containerd's
   runc using `SystemdCgroup = true`. Fix anything that is wrong.
2. On `cp01`, list the existing bootstrap tokens. The old ones have expired — do not
   reuse them.
3. Produce a valid join command on `cp01` without hand-assembling it.
4. Also compute the discovery CA certificate hash from `/etc/kubernetes/pki/ca.crt`
   manually and confirm it matches the hash inside the join command.
5. Run the join on `worker03` and label the node
   `node-role.kubernetes.io/worker=worker`.
6. Confirm `worker03` reaches `Ready` and that a test pod can be scheduled onto it.

## My attempt

```bash

```

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [q02 →](../q02_kustomize_overlay_deploy/question.md)
