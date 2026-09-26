# 9일차 (D-2) — 시간 재고 푸는 미니 모의고사

[← 8일차](day08.md) · [계획 전체](README.md) · [10일차 →](day10.md)

## 오늘의 목표

실제 시험의 **절반 분량**(43점, 51분)을 타이머를 켜고 한 번에 풉니다. 아직 풀지 않은 문제로 골랐고, 시험 비중에 맞춰 트러블슈팅을 가장 많이 넣었습니다. 오늘 보는 것은 실력보다 **시간 배분과 문제를 넘기는 판단**입니다.

## 규칙

- 타이머 **51분**. 중간에 `solution.md`, 이 저장소의 다른 파일, 검색은 보지 않습니다. 시험처럼 kubernetes.io·helm.sh 문서만 봅니다.
- 문제마다 지정된 호스트로 `ssh` → 풀기 → 확인 → `exit`.
- **3분 안에 실마리가 안 보이면 표시하고 다음 문제**로 넘어갑니다. 끝까지 돌고 나서 표시한 문제로 돌아옵니다.
- 순서는 자유입니다. 시험에서처럼 배점이 크고 자신 있는 문제부터 풉니다.

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
