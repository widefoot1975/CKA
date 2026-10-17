# q03 — Explore installed CRDs with kubectl

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_d/q03_crd_explore_explain
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `kubectl get crd | grep cert-manager.io` 에 cert-manager CRD 6개가 보이고, `/opt/course/d03/` 는 비어 있다.
`cleanup.sh` 는 결과 파일만 지운다. cert-manager 까지 지우려면 스크립트의 주석을 해제한다.

## Task

cert-manager is installed in the cluster. Using only `kubectl`, collect information about the
custom resources it added.

1. Write the names of all CustomResourceDefinitions whose API group ends with `cert-manager.io`
   to `/opt/course/d03/crds.txt`, one name per line (for example `certificates.cert-manager.io`).
2. Write the `kubectl explain` documentation of the field `spec.renewBefore` of the
   `Certificate` resource to `/opt/course/d03/renewbefore.txt`.
3. Write the short names of the `certificates` resource to `/opt/course/d03/shortnames.txt`,
   one per line.

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

[↑ 문항 목록](../README.md) · [← q02](../q02_rbac_pod_reader_serviceaccount/question.md) · [q04 →](../q04_kubeadm_cert_renewal/question.md)
