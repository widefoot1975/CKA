# q10 — Add a static DNS record with CoreDNS

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Services & Networking (20%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 처음 실행할 때 원본 Corefile 을 보관하고, 그다음부터는 그 원본으로 되돌린다 (= 이전 실습 흔적 정리)
ORIG=/opt/course/f10-corefile.orig
mkdir -p /opt/course
if [ -f "$ORIG" ]; then
  kubectl -n kube-system create cm coredns --from-file=Corefile="$ORIG" --dry-run=client -o yaml | kubectl replace -f -
  kubectl -n kube-system rollout restart deploy coredns
else
  kubectl -n kube-system get cm coredns -o jsonpath='{.data.Corefile}' > "$ORIG"
fi
kubectl -n kube-system rollout status deploy coredns --timeout=120s

# 1) 백업 파일을 둘 디렉터리 (비어 있는 상태)
rm -rf /opt/course/f10
mkdir -p /opt/course/f10

# 2) 시작 상태 확인: Corefile 에 db.internal 이 없음
kubectl -n kube-system get cm coredns -o jsonpath='{.data.Corefile}' | grep -n 'db.internal' || echo "db.internal 없음 (정상)"
ls -ld /opt/course/f10
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

setup 을 처음 실행할 때 지금의 Corefile 을 `/opt/course/f10-corefile.orig` 에 보관하고, 다시 실행하거나 `cleanup.sh` 를 돌리면 그 원본으로 되돌린 뒤 CoreDNS 를 재시작한다. 그래서 setup 을 처음 돌리기 **전에** Corefile 을 직접 고쳐 두었다면 먼저 원래대로 돌려 놓는다.
`/opt/course/f10/` 는 빈 디렉터리로 만들어 두고, 백업 파일은 문제 1번에서 직접 만든다. CoreDNS 설정은 클러스터 전체에 영향을 주므로 실습이 끝나면 꼭 정리한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
ORIG=/opt/course/f10-corefile.orig
if [ -f "$ORIG" ]; then
  kubectl -n kube-system create cm coredns --from-file=Corefile="$ORIG" --dry-run=client -o yaml | kubectl replace -f -
  kubectl -n kube-system rollout restart deploy coredns
  kubectl -n kube-system rollout status deploy coredns --timeout=120s
  rm -f "$ORIG"
fi
rm -rf /opt/course/f10
```

</details>

## Task

Pods in the cluster must be able to resolve the name `db.internal` to `10.0.0.50`. The
record must be served by the cluster DNS (CoreDNS); do not change the Pods' own
`/etc/hosts`.

1. Back up ConfigMap `coredns` in namespace `kube-system` to
   `/opt/course/f10/coredns-backup.yaml`.
2. Add a `hosts` entry to the Corefile in that ConfigMap so that `db.internal` resolves to
   `10.0.0.50`, while every other name keeps resolving as before.
3. Make sure CoreDNS uses the new configuration. Then verify from a temporary
   `busybox:1.36` Pod that `db.internal` resolves to `10.0.0.50` and that
   `kubernetes.default.svc.cluster.local` still resolves.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
