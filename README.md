# CKA 모의시험 오답 노트

[CKA (Certified Kubernetes Administrator)](https://www.cncf.io/training/certification/cka/) 준비 과정에서 푼 모의시험을 **회차별 → 문제별**로 정리하는 저장소입니다.

- 시험 형식: 실습형(performance-based), **120분**, 합격선 **66%**
- 커리큘럼: [CNCF 공식 curriculum](https://github.com/cncf/curriculum) (v1.35 기준)

> 공개 저장소입니다. 실제 시험 문제 원문은 옮기지 않고, 요구사항을 직접 정리한 표현으로만 기록합니다.

## 디렉터리 구조

```
.
├── mock_exam_01/                   # 모의시험 1회차
│   ├── README.md                   # 회차 요약: 점수, 문항 표, 도메인별 실점, 회고
│   └── q01_etcd_backup_restore/    # 문제 1
│       ├── question.md             # [영문] 환경 / 문제 / 내 풀이 기록란
│       ├── solution.md             # [한글] 모범 풀이 / 검증 / 오답 원인 / 참고 문서 / 복습 기록
│       ├── setup/setup.sh          # 이 문제 상황을 다시 만드는 스크립트
│       ├── manifests/              # 풀이로 작성·수정한 yaml
│       ├── files/                  # 시험 중 손댄 설정 파일 사본 (etcd.yaml, kubelet 설정 등)
│       ├── verify.sh               # 정답 여부 검증
│       └── cleanup.sh              # 원래 상태로 되돌리기
├── mock_exam_02/
├── _template/                      # 새 회차·문제 만들 때 복사할 원본
│   ├── exam_README.md
│   └── question/
├── scripts/new.sh                  # 회차·문제 폴더 생성 스크립트
└── cheatsheet.md                   # 시험장에서 쓸 kubectl 단축 모음
```

폴더 이름 규칙은 `mock_exam_<2자리>` / `q<2자리>_<주제_스네이크케이스>` 입니다. 정렬이 깨지지 않게 번호는 항상 두 자리로 씁니다.

**문제와 풀이는 파일로 분리합니다.** `question.md`를 열어도 답이 보이지 않아야 복습이 됩니다.

| 파일 | 언어 | 내용 |
|---|---|---|
| `question.md` | **영문** | 환경 조건, 문제, 내가 입력한 명령 기록란 |
| `solution.md` | **한글** | 모범 풀이, 검증, 오답 원인, 참고 문서, 복습 기록 |

문제를 영문으로 쓰는 이유는 **실제 시험이 영문이기 때문입니다.** 한글로 읽고 풀다가 시험장에서 영문 지문을 만나면 요구사항을 잘못 읽는 일이 생깁니다. 풀이와 오답 정리는 사고 속도가 빠른 한글로 씁니다.

**문제 폴더는 "읽는 기록"이 아니라 "다시 돌릴 수 있는 실습"으로 둡니다.** `setup.sh`로 상황을 만들고, 직접 풀어 보고, `verify.sh`로 채점하고, `cleanup.sh`로 되돌립니다. 같은 문제를 2주 뒤에 다시 풀 수 있어야 복습이 됩니다.

> `.gitignore`에 `*.key`, `*.crt`, `kubeconfig`, `*.db`를 넣어 두었습니다. 공개 저장소이므로 인증서·kubeconfig·etcd 스냅샷이 실수로 올라가지 않게 막습니다.

## 새 회차 / 문제 추가하기

```bash
# 2회차 폴더 만들기
./scripts/new.sh exam 02

# 2회차에 3번 문제 추가하기
./scripts/new.sh q 02 03 network_policy_deny_all
```

## 진행 현황

| 회차 | 출처 | 응시일 | 점수 | 합격선(66) | 회고 |
|---|---|---|---|---|---|
| [mock_exam_a](mock_exam_a/) | 자체 출제 (17문항, 100점) |  |  / 100 | ☐ | ☐ |
| [mock_exam_01](mock_exam_01/) |  |  |  / 100 | ☐ | ☐ |

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
