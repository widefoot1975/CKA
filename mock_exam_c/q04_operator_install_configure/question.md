# q04 — Install and configure an operator

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_c/q04_operator_install_configure
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후에는 `/opt/course/q04/operator.yaml` 파일만 있고 클러스터에는 아무것도 설치되지 않았다. 설치는 문제 1번에서 한다.
번들의 컨트롤러는 진짜 오퍼레이터가 아니라 `curlimages/curl:8.10.1` 컨테이너가 10초마다 API 서버에 `backups` 를 list 하고, 새 `Backup` 을 보면 로그를 남기고 `status.phase` 를 `Scheduled` 로 채우는 흉내만 낸다.
권한이 없으면 로그에 API 서버의 거부 메시지가 그대로 찍힌다. 문제에 적힌 메시지는 그 줄을 줄여 쓴 것이다.

<details><summary>setup 이 심어 둔 고장 (스포일러)</summary>

번들의 ClusterRole `backup-operator` 에서 `backups`·`backups/status` 규칙의 `apiGroups` 가 `telco.io` 가 아니라 core 그룹 `""` 로 적혀 있다(바로 위 `events` 규칙을 복사해 쓴 실수). ClusterRoleBinding 의 subject 는 맞다.
`cleanup.sh` 는 번들이 만든 것(namespace `backup-system`, CRD, ClusterRole·ClusterRoleBinding `backup-operator`)과 풀이에서 만드는 ClusterRole `backup-viewer`, `default` 의 `viewer-test` ServiceAccount·RoleBinding, `/opt/course/q04` 를 지운다. CRD 를 지우면 `Backup` `nightly` 도 함께 지워진다.

</details>

## Task

The manifest bundle for a backup operator is at `/opt/course/q04/operator.yaml`. It
contains a Namespace, a CRD, a ServiceAccount, a ClusterRole, a ClusterRoleBinding and
the controller Deployment.

1. Install the bundle. The operator must end up in namespace `backup-system`.
2. Report the full resource name, API group, version, short name and scope of the
   custom resource the CRD registers.
3. The controller Deployment `backup-operator` comes up but its log repeatedly shows
   `backups.telco.io is forbidden: cannot list resource "backups"`. Find the cause and
   fix it. Do not grant `cluster-admin`.
4. Everyone bound to the built-in `view` ClusterRole must also be able to read `backups`.
   Achieve this **without editing the `view` ClusterRole**, using a new ClusterRole named
   `backup-viewer`.
5. Once the controller reconciles cleanly, create a `Backup` named `nightly` in namespace
   `default` with `spec.schedule: "0 2 * * *"` and `spec.target: pvc/data-web-0`, and
   show that the controller observed it.

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

[↑ 문항 목록](../README.md) · [← q03](../q03_cni_install_networkpolicy/question.md) · [q05 →](../q05_statefulset_daemonset_selfheal/question.md)
