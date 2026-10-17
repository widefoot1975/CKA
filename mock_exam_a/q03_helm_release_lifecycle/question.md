# q03 — Manage a cluster component with Helm

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_a/q03_helm_release_lifecycle
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 클러스터에 cert-manager(릴리스·CRD·namespace)가 하나도 없고, `jetstack` 저장소도 없으며 `/root/helm/` 은 비어 있다.
**주의:** 이 setup 은 `mock_exam_d/q03` 이 쓰는 cert-manager 도 지운다. d03 을 다시 풀 때는 d03 의 setup 을 다시 돌리면 된다(이 문제의 Helm 설치가 남아 있으면 d03 setup 은 그대로 쓴다).
차트와 이미지를 받아야 하므로 `charts.jetstack.io` 와 `quay.io` 로 인터넷 연결이 되어야 한다.

## Task

Use Helm to install cert-manager as a cluster component in namespace `cert-manager`.
Write every answer file under `/root/helm/`.

1. Add the chart repository `jetstack` at `https://charts.jetstack.io`, refresh the index,
   and write the latest version of chart `jetstack/cert-manager` to
   `/root/helm/version.txt`. Pass exactly that version with `--version` in every later step.
2. Save the chart's default values to `/root/helm/values.yaml` **without installing
   anything**, and write the names of the values that control CRD installation to
   `/root/helm/crd-values.txt`.
3. Install release `cert-manager` into `cert-manager`, creating the namespace, with the
   CRDs installed by the chart and the controller running `2` replicas.
4. Upgrade the release so the controller runs `3` replicas **without losing any value set
   in step 3**. Show the release history, roll back to revision 1, and confirm the
   controller is back to 2 replicas and the CRDs still exist.
5. Using only `kubectl`, write the documentation of the field `spec.dnsNames` of the
   `Certificate` resource to `/root/helm/dnsnames.txt`.

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

[↑ 문항 목록](../README.md) · [← q02](../q02_kubeadm_cluster_upgrade/question.md) · [q04 →](../q04_kubeconfig_certificate_management/question.md)
