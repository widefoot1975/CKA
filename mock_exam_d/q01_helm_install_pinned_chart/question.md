# q01 — Install and upgrade a Helm release

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) helm 이 설치되어 있는지 확인 (없으면 여기서 멈춘다)
helm version --short

# 1) 이전 실습 흔적 정리: 릴리스, 네임스페이스, 저장소, 결과 파일
if helm status podinfo -n demo >/dev/null 2>&1; then
  helm uninstall podinfo -n demo --wait
fi
kubectl delete ns demo --ignore-not-found --wait=true
helm repo remove podinfo >/dev/null 2>&1 || true
rm -rf /opt/course/d01

# 2) 결과 파일 디렉터리
mkdir -p /opt/course/d01

# 3) 시작 상태 확인: 저장소·네임스페이스·릴리스가 모두 없어야 한다
helm repo list 2>/dev/null | grep podinfo || echo "podinfo 저장소 없음 (정상)"
kubectl get ns demo 2>/dev/null || echo "namespace demo 없음 (정상)"
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `podinfo` 차트 저장소, namespace `demo`, 릴리스 `podinfo` 는 모두 없고 `/opt/course/d01/` 는 비어 있다. 저장소 추가부터 문제에서 직접 한다.
차트를 받아야 하므로 `k8s-c1` 에서 `stefanprodan.github.io` 와 `ghcr.io` 로 인터넷 연결이 되어야 한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
if helm status podinfo -n demo >/dev/null 2>&1; then
  helm uninstall podinfo -n demo --wait
fi
kubectl delete ns demo --ignore-not-found
helm repo remove podinfo >/dev/null 2>&1 || true
rm -rf /opt/course/d01
```

</details>

## Task

The team wants the `podinfo` demo application installed with Helm. The chart version must be
pinned so that every later change uses exactly the same chart.

1. Add the chart repository `podinfo` at `https://stefanprodan.github.io/podinfo`, refresh the
   repository index, and write the latest version of chart `podinfo/podinfo` shown by
   `helm search repo` to `/opt/course/d01/version.txt`.
2. Install release `podinfo` from chart `podinfo/podinfo` into namespace `demo` (create the
   namespace), passing exactly that version with `--version` and setting `replicaCount=2`.
3. Upgrade the release, with the same chart version, to set `ui.message=hello-cka` without
   losing the `replicaCount` set in step 2.
4. Confirm that the release history shows 2 revisions and that the release's Deployment runs
   2 ready pods.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
