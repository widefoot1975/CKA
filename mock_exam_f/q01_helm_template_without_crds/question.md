# q01 — Render and install a chart without its CRDs

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_f/q01_helm_template_without_crds
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

`k8s-c1` 에 `helm` 이 설치되어 있고 인터넷에 연결되어 있어야 한다. Argo CD CRD 세 개(`applications`, `applicationsets`, `appprojects` `.argoproj.io`)를 Helm 밖에서 `kubectl apply --server-side` 로 설치하고, 저장소 `argo`·릴리스 `argocd`·네임스페이스 `argocd` 는 지운 상태로 시작한다.
CRD 는 argo-cd `stable` 브랜치에서 받으므로 최신 차트와 버전이 거의 맞는다. `cleanup.sh` 는 릴리스와 CRD 까지 지운다.

## Task

The Argo CD CustomResourceDefinitions (`*.argoproj.io`) are already installed in the
cluster and are managed outside of Helm. Argo CD itself must now be installed with Helm,
without the chart creating or managing those CRDs.

1. Add the chart repository `https://argoproj.github.io/argo-helm` with the name `argo`.
   Write the latest version of chart `argo/argo-cd` shown by `helm search repo` to
   `/opt/course/f01/version.txt`, and use exactly that version in the next steps.
2. Render the chart with `helm template` using release name `argocd`, namespace `argocd`
   and the value `crds.install=false`. Save the output to `/opt/course/f01/argocd.yaml`.
3. Install release `argocd` into namespace `argocd` (create the namespace) with the same
   chart version and the same value.
4. Confirm that `/opt/course/f01/argocd.yaml` contains no `kind: CustomResourceDefinition`
   and that `helm list -n argocd` shows the release as `deployed`.

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

[↑ 문항 목록](../README.md) · [q02 →](../q02_clusterrole_rolebinding_scope/question.md)
