# CKA 모의시험 오답 노트

[CKA (Certified Kubernetes Administrator)](https://www.cncf.io/training/certification/cka/) 준비 과정에서 푼 모의시험을 **회차별 → 문제별**로 정리하는 저장소입니다.

- 시험 형식: 실습형(performance-based), **120분**, 합격선 **66%**
- 커리큘럼: [CNCF 공식 curriculum](https://github.com/cncf/curriculum) (v1.35 기준)

> 공개 저장소입니다. 실제 시험 문제 원문은 옮기지 않고, 요구사항을 직접 정리한 표현으로만 기록합니다.

## 디렉터리 구조

```
.
├── README.md                                   # 이 파일 — 진행 현황, 도메인별 자신감, 반복 오답
├── cheatsheet.md                               # 시험장에서 쓸 kubectl 단축과 빈출 절차
├── .gitignore
└── mock_exam_a/                                # 모의시험 1회차 (자체 출제 17문항, 배점 합계 100)
    ├── README.md                               # 회차 요약: 문항 표, 도메인별 실점, 회고
    ├── q01_rbac_serviceaccount/
    │   ├── question.md                         # [영문] 문제
    │   └── solution.md                         # [한글] 해석 + 풀이
    ├── q02_etcd_backup_restore/
    ├── q03_kubeadm_upgrade/
    ├── q04_node_drain_maintenance/
    ├── q05_deployment_rollout_rollback/
    ├── q06_scheduling_affinity_taint/
    ├── q07_configmap_secret_injection/
    ├── q08_service_nodeport/
    ├── q09_ingress_path_routing/
    ├── q10_networkpolicy_default_deny/
    ├── q11_pv_pvc_static/
    ├── q12_storageclass_dynamic_expand/
    ├── q13_node_notready_kubelet/
    ├── q14_pod_crashloopbackoff/
    ├── q15_service_no_endpoints/
    ├── q16_static_pod_manifest_error/
    └── q17_coredns_resolution_failure/
```

회차 폴더는 `mock_exam_<문자 또는 2자리>`, 문제 폴더는 `q<2자리>_<주제_스네이크케이스>` 입니다. 정렬이 깨지지 않게 문제 번호는 항상 두 자리로 씁니다.

## 문제와 풀이를 파일로 나누는 이유

문제 폴더에 `README.md`를 두지 않습니다. GitHub는 폴더를 열면 README를 자동으로 펼치기 때문에, 그 안에 답이 있으면 볼 때마다 스포일러가 됩니다.

| 파일 | 언어 | 내용 |
|---|---|---|
| `question.md` | **영문** | 메타 표, 문제(`## Task`), 내가 입력한 명령 기록란 |
| `solution.md` | **한글** | 문제 해석 → 모범 풀이 → 검증 → 오답 원인 → 참고 문서 → 복습 기록 |

**문제를 영문으로 쓰는 이유는 실제 시험이 영문이기 때문입니다.** 한글로만 풀다가 시험장에서 영문 지문을 만나면 요구사항을 잘못 읽는 일이 생깁니다. `solution.md` 맨 앞에 **한글 해석**을 두었으니, 풀이를 보기 전에 내가 영문을 제대로 읽었는지 먼저 대조하세요. 풀이와 오답 정리는 사고 속도가 빠른 한글로 씁니다.

## 푸는 순서

1. `mock_exam_a/README.md` 의 문항 표에서 문제를 고릅니다.
2. `question.md` **만** 엽니다. 맨 위 컨텍스트 전환(`kubectl config use-context`)을 먼저 실행합니다 — 실제 시험에서 이걸 빼먹으면 그 문제는 0점입니다.
3. 직접 풀고, 입력한 명령을 `question.md` 의 `## My attempt` 에 그대로 붙입니다. **틀린 명령도 지우지 마세요.** 그게 오답 노트의 내용입니다.
4. `solution.md` 를 엽니다. 한글 해석으로 문제를 제대로 읽었는지 먼저 확인하고, 그다음 모범 풀이와 비교합니다.
5. 틀렸으면 `## 오답 원인 / 배운 점` 을 채우고, 회차 README 의 결과 칸과 이 파일의 도메인별 손실을 갱신합니다.

## 새 회차 / 문제 추가하기

```bash
mkdir -p mock_exam_b/q01_<주제_스네이크케이스>
# question.md (영문) 와 solution.md (한글) 를 만들고
# mock_exam_b/README.md 문항 표에 한 줄 추가
```

> `.gitignore` 에 `*.key`, `*.crt`, `kubeconfig`, `*.db` 를 넣어 두었습니다. 공개 저장소이므로 인증서·kubeconfig·etcd 스냅샷이 실수로 올라가지 않게 막습니다.

## 진행 현황

| 회차 | 출처 | 문항 | 응시일 | 점수 | 합격(66) | 회고 |
|---|---|---|---|---|---|---|
| [mock_exam_a](mock_exam_a/) | 자체 출제 | 17 |  |  / 100 | ☐ | ☐ |

## 도메인별 자신감

비중은 공식 커리큘럼 기준입니다. 모의시험을 볼 때마다 손실 점수를 여기에 누적해서, 공부 시간을 어디에 쓸지 결정합니다.

| 도메인 | 비중 | 누적 손실 | 자신감 | 약점 메모 |
|---|---|---|---|---|
| Troubleshooting | 30% |  | ☐☐☐☐☐ |  |
| Cluster Architecture, Installation & Configuration | 25% |  | ☐☐☐☐☐ |  |
| Services & Networking | 20% |  | ☐☐☐☐☐ |  |
| Workloads & Scheduling | 15% |  | ☐☐☐☐☐ |  |
| Storage | 10% |  | ☐☐☐☐☐ |  |

**Troubleshooting이 30%로 가장 큽니다.** 배점 순서대로 공부하는 것이 점수 대비 효율이 가장 좋습니다.

## 반복 오답 목록

같은 주제를 두 번 이상 틀리면 여기에 올립니다. 시험 전날 이 표만 봅니다.

| 주제 | 틀린 횟수 | 관련 문제 | 해결했나 |
|---|---|---|---|
|  |  |  | ☐ |
