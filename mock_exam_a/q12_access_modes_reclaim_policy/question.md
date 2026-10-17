# q12 — Access modes and reclaim policy

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
NODE=${NODE:-worker01}
kubectl get node "$NODE" >/dev/null
ssh "$NODE" true

# 0) 이전 실습 흔적 정리: 파드 → PVC → PV 순서로 지운다 (보호 finalizer 때문에 순서가 중요)
if kubectl get ns ops >/dev/null 2>&1; then
  kubectl -n ops delete pod writer reader --ignore-not-found --wait=true
  kubectl -n ops delete pvc pvc-a pvc-b pvc-d pvc-rwx --ignore-not-found --wait=true
fi
kubectl delete pv pv-retain pv-delete --ignore-not-found --wait=true

# 1) worker01 의 hostPath 디렉터리를 비운다 (지난번 파일이 남아 있으면 3단계 증명이 의미가 없다)
#    A11 의 /mnt/data/logs 는 건드리지 않는다
ssh "$NODE" sudo rm -rf /mnt/data/retain /mnt/data/delete

# 2) namespace ops 가 없으면 만든다
kubectl get ns ops >/dev/null 2>&1 || kubectl create ns ops

# 3) StorageClass slow 가 있으면 5단계 결과가 달라지므로 경고만 한다 (이 문제는 slow 를 PV 의 클래스 이름으로만 쓴다)
kubectl get sc slow >/dev/null 2>&1 && echo "경고: StorageClass slow 가 이미 있다 — 5단계에서 동적 프로비저닝이 일어날 수 있음"

# 4) 시작 상태 확인: pv-retain / pv-delete 가 없고, ops 에 이 문제의 PVC 가 없어야 함
kubectl get pv
kubectl -n ops get pvc
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

이 문제는 1단계에서 PV 를 직접 만드는 것부터 시작하므로, setup 은 이전 흔적(파드 `writer`·`reader`, PVC `pvc-a`·`pvc-b`·`pvc-d`·`pvc-rwx`, PV `pv-retain`·`pv-delete`)과 worker01 의 `/mnt/data/retain`·`/mnt/data/delete` 를 지우고 namespace `ops` 만 준비한다.
`ops` 는 A11 도 쓰므로 setup·cleanup 은 namespace 를 지우지 않고 이 문제의 리소스만 이름으로 지운다. worker01 로 ssh 가 되고 그곳에서 암호 없는 sudo 가 되어야 한다. StorageClass `slow` 는 만들지 않는다(이 문제에서 `slow` 는 PV 에 붙이는 클래스 이름일 뿐이다).

<details><summary>정리 명령 (방법 A)</summary>

```bash
NODE=${NODE:-worker01}
if kubectl get ns ops >/dev/null 2>&1; then
  kubectl -n ops delete pod writer reader --ignore-not-found --wait=true
  kubectl -n ops delete pvc pvc-a pvc-b pvc-d pvc-rwx --ignore-not-found --wait=true
fi
kubectl delete pv pv-retain pv-delete --ignore-not-found --wait=true
ssh "$NODE" sudo rm -rf /mnt/data/retain /mnt/data/delete
```

</details>

## Task

A claim was deleted by mistake and its volume must be reused without losing the data.

1. Create two PersistentVolumes in class `slow`, both 1Gi, `ReadWriteOnce` and pinned to
   node `worker01` with node affinity: `pv-retain` with reclaim policy `Retain` on
   `hostPath` `/mnt/data/retain`, and `pv-delete` with reclaim policy `Delete` on
   `hostPath` `/mnt/data/delete`.
2. In namespace `ops`, create a claim `pvc-a` that is guaranteed to bind to `pv-retain`
   (not merely to any matching volume), write a file to it from a Pod `writer`
   (`busybox:1.36`), then delete the Pod and the claim.
3. Report the `STATUS` of `pv-retain` now, bring it back to `Available` without deleting
   the PV, and prove with a new claim `pvc-b` and a Pod `reader` that the file survived.
4. Bind a claim `pvc-d` to `pv-delete`, delete the claim, and report the `STATUS` of
   `pv-delete` together with the event that explains it.
5. Create a claim `pvc-rwx` in `ops` requesting `ReadWriteMany` from class `slow` and state
   in one line why it does not bind.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
