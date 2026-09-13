# CKA 모의시험 오답 노트

[CKA (Certified Kubernetes Administrator)](https://www.cncf.io/training/certification/cka/) 준비 과정에서 푼 모의시험을 **회차별 → 문제별**로 정리하는 저장소입니다.

- 시험 형식: 실습형(performance-based), **120분**, 합격선 **66%**
- 커리큘럼: [CNCF 공식 curriculum](https://github.com/cncf/curriculum) — **v1.35** 기준

> 공개 저장소입니다. 실제 시험 문제 원문은 옮기지 않고, 요구사항을 직접 정리한 표현으로만 기록합니다.

## 출제 범위와 트렌드

공식 커리큘럼(`CKA_Curriculum_v1.35.pdf`)의 도메인과 비중입니다. **배점 순서가 곧 공부 순서**입니다.

| 도메인 | 비중 | 세부 항목 |
|---|---|---|
| **Troubleshooting** | **30%** | 클러스터·노드 / 클러스터 컴포넌트 / **리소스 사용량 모니터링** / **컨테이너 출력 스트림** / 서비스·네트워킹 |
| **Cluster Architecture, Installation & Configuration** | **25%** | RBAC / 인프라 사전 준비 / kubeadm / 클러스터 수명주기 / **HA 컨트롤 플레인** / **Helm·Kustomize** / **확장 인터페이스(CNI·CSI·CRI)** / **CRD·operator** |
| **Servicing & Networking** | **20%** | 파드 간 연결성 / NetworkPolicy / Service 타입·엔드포인트 / **Gateway API** / Ingress / CoreDNS |
| **Workloads & Scheduling** | **15%** | 롤링 업데이트·롤백 / ConfigMap·Secret / **워크로드 오토스케일링** / 자가 치유 primitives / 파드 admission·스케줄링 |
| **Storage** | **10%** | StorageClass·동적 프로비저닝 / 볼륨 타입·접근 모드·reclaim 정책 / PV·PVC 관리 |

### 2025년 개정으로 들어온 것들 (굵게 표시한 항목)

CKA는 2025년에 커리큘럼이 크게 개정되면서 **"클러스터를 운영한다"에서 "클러스터를 확장하고 현대적 도구로 다룬다"** 쪽으로 무게가 옮겨갔습니다. 예전 자료로만 공부하면 아래를 통째로 빠뜨립니다.

| 신규 항목 | 무엇을 묻나 |
|---|---|
| **Helm** | 차트 저장소 추가, 릴리스 설치·업그레이드·롤백, `--reuse-values`, 히스토리 |
| **Kustomize** | base/overlay 구조, `namePrefix`·`images`·`replicas`·patch, `kubectl apply -k` |
| **Gateway API** | GatewayClass / Gateway / HTTPRoute, 경로 매칭, 가중치 기반 트래픽 분할 |
| **CRD·operator** | CRD 설치, 커스텀 리소스 생성, `kubectl api-resources` 로 확인, operator 배포 |
| **워크로드 오토스케일링** | HPA(`autoscaling/v2`), resource requests 전제, metrics-server 의존성 |
| **확장 인터페이스** | CRI(`crictl`), CNI 설정과 장애, CSI 드라이버·`volumeMode` |
| **HA 컨트롤 플레인** | 멤버 구성·검증, 한 멤버 장애 시 진단 |
| **리소스 사용량 모니터링** | metrics-server, `kubectl top`, 요청·제한 대비 실사용 분석 |
| **컨테이너 출력 스트림** | `kubectl logs` 의 `--previous`·`-c`·`--all-containers`, 사이드카 로깅 |

### 반대로 비중이 줄어든 것

- **etcd 백업·복구**가 커리큘럼 항목에서 빠졌습니다. "클러스터 수명주기 관리"에 흡수된 형태라 안 나온다고 단정할 수는 없지만, 예전처럼 고정 출제로 보고 시간을 크게 쓸 이유는 줄었습니다.
- 도메인 이름도 *Services and Networking* → **Servicing and Networking** 으로 바뀌었습니다.

### 출제 형태

- 전 문항이 실습형입니다. 객관식이 없습니다.
- 문제마다 **컨텍스트 전환**(`kubectl config use-context ...`)이 먼저 주어집니다. 이걸 빼먹으면 정답을 만들어도 0점입니다.
- 시험 중 열람 가능한 문서는 kubernetes.io 계열로 제한됩니다. Helm처럼 그 밖에 있는 도구는 `--help` 로 찾는 연습이 필요합니다.
- 배점이 문제마다 표시됩니다. 큰 것부터 푸는 것이 정석이고, 3분 안에 진입점이 안 보이면 넘어갑니다.

### 시간 예산

120분에 100점이므로 **1점당 1.2분**이 실제 배분입니다. 이 저장소는 여기에 맞춰 문항마다 `목표` 시간을 넣어 두었습니다.

| 구분 | 배분 | 이유 |
|---|---|---|
| 일반 문항 | 배점 × **1분** | 리소스를 만들고 검증하는 작업 |
| Troubleshooting | 배점 × **1.33분** | 원인을 좁히는 시간이 더 든다 |
| 합계 | **110분** | 남는 10분은 컨텍스트 전환과 마지막 검증용 |

목표 시간은 **측정값이 아니라 예산**입니다. 실제 벽시계 시간이 예산을 넘는 작업도 있습니다 — 패키지 설치를 기다리는 `kubeadm` 업그레이드, 정적 파드 재시작 대기 같은 것들이 그렇습니다. **그런 문항은 배점 대비 시간이 나쁘다는 신호이므로 시험장에서는 뒤로 미루는 것이 맞습니다.** 예산을 어디서 넘겼는지가 다음에 공부할 주제입니다.

풀고 나면 `question.md` 의 `Actual time` 과 회차 README의 `실제` 칸에 실제 걸린 시간을 적으세요.

## 디렉터리 구조

```
.
├── README.md                   # 이 파일 — 출제 트렌드, 진행 현황, 도메인별 자신감, 반복 오답
├── cheatsheet.md               # 시험장에서 쓸 kubectl 단축과 빈출 절차
├── .gitignore
├── mock_exam_a/                # 모의고사 A — 17문항 100점
│   ├── README.md               # 회차 요약: 문항 표, 도메인별 실점, 회고
│   └── q01_… ~ q17_…/
│       ├── question.md         # [영문] 문제
│       └── solution.md         # [한글] 해석 + 풀이
├── mock_exam_b/                # 모의고사 B — 17문항 100점
└── mock_exam_c/                # 모의고사 C — 17문항 100점
```

**A·B·C는 각각 독립된 전 범위 모의고사입니다.** 세 세트 모두 공식 도메인 비중(30/25/20/15/10)을 그대로 지키고, 문제는 서로 겹치지 않습니다. 한 세트만 풀어도 범위가 치우치지 않고, 세 세트를 다 풀면 커리큘럼 항목을 여러 각도로 훑게 됩니다.

## 문제와 풀이를 파일로 나누는 이유

문제 폴더에 `README.md`를 두지 않습니다. GitHub는 폴더를 열면 README를 자동으로 펼치기 때문에, 그 안에 답이 있으면 볼 때마다 스포일러가 됩니다.

| 파일 | 언어 | 내용 |
|---|---|---|
| `question.md` | **영문** | 메타 표, 문제(`## Task`), 내가 입력한 명령 기록란 |
| `solution.md` | **한글** | 문제 해석 → 모범 풀이 → 검증 → 오답 원인 → 참고 문서 → 복습 기록 |

**문제를 영문으로 쓰는 이유는 실제 시험이 영문이기 때문입니다.** 한글로만 풀다가 시험장에서 영문 지문을 만나면 요구사항을 잘못 읽는 일이 생깁니다. `solution.md` 맨 앞에 **한글 해석**을 두었으니, 풀이를 보기 전에 내가 영문을 제대로 읽었는지 먼저 대조하세요.

## 푸는 순서

1. 회차 `README.md` 의 문항 표에서 문제를 고릅니다.
2. `question.md` **만** 엽니다. 맨 위 컨텍스트 전환을 먼저 실행합니다.
3. 직접 풀고, 입력한 명령을 `## My attempt` 에 그대로 붙입니다. **틀린 명령도 지우지 마세요.**
4. `solution.md` 를 엽니다. 한글 해석으로 문제를 제대로 읽었는지 먼저 확인하고, 그다음 모범 풀이와 비교합니다.
5. 틀렸으면 `## 오답 원인 / 배운 점` 을 채우고, 회차 README의 결과 칸과 아래 도메인별 손실을 갱신합니다.

## 새 회차 / 문제 추가하기

```bash
mkdir -p mock_exam_d/q01_<주제_스네이크케이스>
# question.md (영문) 와 solution.md (한글) 를 만들고
# mock_exam_d/README.md 문항 표에 한 줄 추가
```

> `.gitignore` 에 `*.key`, `*.crt`, `kubeconfig`, `*.db` 를 넣어 두었습니다. 공개 저장소이므로 인증서·kubeconfig·etcd 스냅샷이 실수로 올라가지 않게 막습니다.

## 진행 현황

| 회차 | 문항 | 배점 | 목표 시간 | 응시일 | 실제 소요 | 점수 | 합격(66) | 회고 |
|---|---|---|---|---|---|---|---|---|
| [mock_exam_a](mock_exam_a/) | 17 | 100 | 110분 |  |  |  / 100 | ☐ | ☐ |
| [mock_exam_b](mock_exam_b/) | 17 | 100 | 110분 |  |  |  / 100 | ☐ | ☐ |
| [mock_exam_c](mock_exam_c/) | 17 | 100 | 110분 |  |  |  / 100 | ☐ | ☐ |

## 도메인별 자신감

모의시험을 볼 때마다 손실 점수를 누적해서, 공부 시간을 어디에 쓸지 결정합니다.

| 도메인 | 비중 | A 손실 | B 손실 | C 손실 | 자신감 | 약점 메모 |
|---|---|---|---|---|---|---|
| Troubleshooting | 30% |  |  |  | ☐☐☐☐☐ |  |
| Cluster Architecture, Installation & Configuration | 25% |  |  |  | ☐☐☐☐☐ |  |
| Servicing & Networking | 20% |  |  |  | ☐☐☐☐☐ |  |
| Workloads & Scheduling | 15% |  |  |  | ☐☐☐☐☐ |  |
| Storage | 10% |  |  |  | ☐☐☐☐☐ |  |

## 반복 오답 목록

같은 주제를 두 번 이상 틀리면 여기에 올립니다. 시험 전날 이 표만 봅니다.

| 주제 | 틀린 횟수 | 관련 문제 | 해결했나 |
|---|---|---|---|
|  |  |  | ☐ |
