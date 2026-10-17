# 9일차 (D-2) — 시간 재고 푸는 미니 모의고사

[← 8일차](day08.md) · [계획 전체](README.md) · [10일차 →](day10.md)

## 오늘의 목표

실제 시험의 **절반 분량**(43점, 51분)을 타이머를 켜고 한 번에 풉니다. 아직 풀지 않은 문제로 골랐고, 시험 비중에 맞춰 트러블슈팅을 가장 많이 넣었습니다. 오늘 보는 것은 실력보다 **시간 배분과 문제를 넘기는 판단**입니다.

## 규칙

- 타이머 **51분**. 중간에 `solution.md`, 이 저장소의 다른 파일, 검색은 보지 않습니다. 시험처럼 kubernetes.io·helm.sh 문서만 봅니다.
- 문제마다 지정된 호스트로 `ssh` → 풀기 → 확인 → `exit`.
- **3분 안에 실마리가 안 보이면 표시하고 다음 문제**로 넘어갑니다. 끝까지 돌고 나서 표시한 문제로 돌아옵니다.
- 순서는 자유입니다. 시험에서처럼 배점이 크고 자신 있는 문제부터 풉니다.

## 환경 준비 (타이머 켜기 전)

7문제의 환경을 한 클러스터에 **한꺼번에** 만들어 두고 시작합니다. 각 문제 페이지의 Setup 섹션과 같은 스크립트를 순서만 맞춰 실행하는 것입니다. 저장소를 `k8s-c1` 의 `~/CKA` 에 받아 두었다고 가정합니다(다른 곳이면 첫 줄만 바꿉니다).

```bash
cd ~/CKA
bash mock_exam_f/q13_kubelet_wrong_runtime_endpoint/setup.sh   # 1. worker02 를 NotReady 로 (먼저 해야 이후 파드가 worker02 를 피한다)
bash mock_exam_f/q01_helm_template_without_crds/setup.sh       # 2
bash mock_exam_f/q02_clusterrole_rolebinding_scope/setup.sh    # 3
bash mock_exam_f/q11_pv_reclaim_policy_patch/setup.sh          # 4
bash mock_exam_f/q15_service_targetport_mismatch/setup.sh      # 5
bash mock_exam_e/q16_coredns_scaled_to_zero/setup.sh           # 6. 클러스터 DNS 가 멈춘다
bash mock_exam_f/q14_kubeconfig_wrong_port/setup.sh            # 7. 반드시 마지막 (이후 kubectl 이 안 된다)
clear                                                          # 설정 출력에 답의 실마리가 보이므로 지운다
```

순서에는 이유가 있습니다. 문제끼리 서로 영향을 주기 때문입니다.

- **F14 를 풀기 전에는 `k8s-c1` 에서 kubectl 이 전부 실패합니다.** 그래서 F14 setup 이 맨 마지막이고, 시험을 시작하면 F14 를 가장 먼저 풀어야 다른 문제로 넘어갈 수 있습니다. 실제 시험에서는 문제마다 클러스터가 따로라 이런 일이 없습니다.
- **E16 을 풀기 전에는 클러스터 DNS 가 없습니다.** F15 의 마지막 확인(`wget http://payments`)처럼 Service 이름을 쓰는 확인은 E16 을 고친 뒤에 합니다. F01 의 Argo CD 파드 일부도 DNS 가 없으면 Ready 가 늦어질 수 있지만, F01 은 `helm list` 에서 `deployed` 면 됩니다.
- **F13 을 먼저 실행하는 이유**: `worker02` 가 NotReady 가 되면 새 파드가 그 노드에 배치되지 않습니다. 그래서 F11 의 볼륨과 F15 의 파드가 처음부터 정상 노드에 만들어져, `worker02` 가 멈춰 있는 동안에도 영향을 받지 않습니다.
- F01·F02·F11·F15 는 서로 다른 네임스페이스(`argocd`, `team-a`/`team-b`, `db`, `shop`)와 결과 디렉터리(`/opt/course/<문제>`)를 쓰므로 겹치지 않습니다.

채점까지 끝나면 정리합니다. kubectl 이 필요하므로 **F14 를 먼저 되돌립니다.**

```bash
cd ~/CKA
for q in mock_exam_f/q14_kubeconfig_wrong_port mock_exam_e/q16_coredns_scaled_to_zero \
         mock_exam_f/q13_kubelet_wrong_runtime_endpoint mock_exam_f/q15_service_targetport_mismatch \
         mock_exam_f/q11_pv_reclaim_policy_patch mock_exam_f/q02_clusterrole_rolebinding_scope \
         mock_exam_f/q01_helm_template_without_crds; do
  bash $q/cleanup.sh
done
```

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:51 | 아래 7문제 풀기 (타이머) |
| 0:51 – 1:00 | 채점: 각 `solution.md` 의 검증 단계로 맞았는지 확인하고 점수를 적습니다 |

풀이를 꼼꼼히 비교하는 것은 내일 오답 복습 시간에 합니다.

## 문제

| 문제 | 도메인 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|---|
| F13 | Troubleshooting | kubelet 설정 변경 후 노드 NotReady | 7 | 9분 | [Q](../mock_exam_f/q13_kubelet_wrong_runtime_endpoint/question.md) · [S](../mock_exam_f/q13_kubelet_wrong_runtime_endpoint/solution.md) ☐ |
| F14 | Troubleshooting | kubectl이 API 서버에 연결되지 않음 | 6 | 8분 | [Q](../mock_exam_f/q14_kubeconfig_wrong_port/question.md) · [S](../mock_exam_f/q14_kubeconfig_wrong_port/solution.md) ☐ |
| F15 | Troubleshooting | 엔드포인트는 있는데 연결 거부 | 6 | 8분 | [Q](../mock_exam_f/q15_service_targetport_mismatch/question.md) · [S](../mock_exam_f/q15_service_targetport_mismatch/solution.md) ☐ |
| E16 | Troubleshooting | 클러스터 DNS 장애 | 6 | 8분 | [Q](../mock_exam_e/q16_coredns_scaled_to_zero/question.md) · [S](../mock_exam_e/q16_coredns_scaled_to_zero/solution.md) ☐ |
| F01 | Cluster Arch | CRD를 빼고 차트 렌더링·설치 | 7 | 7분 | [Q](../mock_exam_f/q01_helm_template_without_crds/question.md) · [S](../mock_exam_f/q01_helm_template_without_crds/solution.md) ☐ |
| F02 | Cluster Arch | ClusterRole을 한 네임스페이스에서만 사용 | 6 | 6분 | [Q](../mock_exam_f/q02_clusterrole_rolebinding_scope/question.md) · [S](../mock_exam_f/q02_clusterrole_rolebinding_scope/solution.md) ☐ |
| F11 | Storage | 동적 프로비저닝된 볼륨 보호 | 5 | 5분 | [Q](../mock_exam_f/q11_pv_reclaim_policy_patch/question.md) · [S](../mock_exam_f/q11_pv_reclaim_policy_patch/solution.md) ☐ |

합계 **43점**, 목표 **51분**.

## 결과 기록

| 항목 | 값 |
|---|---|
| 걸린 시간 | 분 |
| 점수 | / 43 |
| 환산 (÷ 0.43) | / 100 — 66 이상이면 합격선 |
| 표시하고 넘긴 문제 | |
| 목표 시간을 가장 많이 넘긴 문제 | |

**목표 시간을 가장 많이 넘긴 문제가 내일 복습할 주제입니다.** 시험장에서도 같은 유형은 뒤로 미룹니다.
