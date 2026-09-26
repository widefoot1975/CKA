# 1일차 (D-10) — 시험 형식과 명령형 속도

[← 계획 전체](README.md) · [2일차 →](day02.md)

## 오늘의 목표

- 시험이 어떻게 진행되는지(문제마다 `ssh`, 120분, 66점) 머리에 넣습니다.
- 매니페스트를 처음부터 쓰지 않고 **명령형으로 뼈대를 만드는 손버릇**을 들입니다. 이후 9일 동안 모든 문제의 속도가 여기서 결정됩니다.

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:15 | [exam_guide.md](../exam_guide.md) §1 시험 형식과 환경, §2 시간 전략과 터미널 습관, §3 2025~2026 트렌드 |
| 0:15 – 0:20 | [cheatsheet.md](../cheatsheet.md) §0 ~ §2 (호스트에 들어갈 때마다, 문제마다, 매니페스트 빨리 만들기) |
| 0:20 – 0:45 | 아래 문제 4개 풀기 |
| 0:45 – 0:57 | `solution.md` 와 대조, 오답 원인 기록 |
| 0:57 – 1:00 | 회차 README의 `실제`·`결과` 칸 채우기 |

## 풀 문제

| 문제 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|
| D05 | Deployment 스케일·이미지 변경·롤백 | 5 | 5분 | [Q](../mock_exam_d/q05_deployment_scale_rollout_undo/question.md) · [S](../mock_exam_d/q05_deployment_scale_rollout_undo/solution.md) ☐ |
| D06 | ConfigMap을 환경 변수와 파일로 주입 | 5 | 5분 | [Q](../mock_exam_d/q06_configmap_env_and_volume/question.md) · [S](../mock_exam_d/q06_configmap_env_and_volume/solution.md) ☐ |
| D09 | NodePort Service로 컨테이너 포트 공개 | 7 | 7분 | [Q](../mock_exam_d/q09_nodeport_expose_container_port/question.md) · [S](../mock_exam_d/q09_nodeport_expose_container_port/solution.md) ☐ |
| E10 | 이름 붙은 컨테이너 포트를 가리키는 Service | 6 | 6분 | [Q](../mock_exam_e/q10_service_named_targetport/question.md) · [S](../mock_exam_e/q10_service_named_targetport/solution.md) ☐ |

합계 23점, 목표 23분.

## 꼭 잡을 것

```bash
export do="--dry-run=client -o yaml"
kubectl create deploy web --image=nginx:1.27 --replicas=3 $do > web.yaml
kubectl create cm app-cfg --from-literal=MODE=prod $do
kubectl expose deploy web --type=NodePort --port=80 --target-port=8080 $do
kubectl explain pod.spec.containers.envFrom      # 필드 이름이 기억 안 날 때
```

- `$do` 를 `--` 뒤에 쓰면 컨테이너 인자가 되어 **오브젝트가 실제로 만들어집니다** (함정 3).
- `kubectl set image deploy/<배포> <컨테이너이름>=<이미지>` — 가운데는 **컨테이너 이름**입니다 (함정 5).
- `targetPort` 를 생략하면 `port` 와 같은 값이 됩니다. Service 포트와 컨테이너 포트를 헷갈리지 않습니다 (함정 28).
- Endpoints 대신 `kubectl get endpointslice -l kubernetes.io/service-name=<svc>` 로 확인합니다 (함정 30).

## 여유가 있으면

- 심화 [A05 롤링 업데이트·일시정지·롤백](../mock_exam_a/q05_deployment_rollout_rollback/question.md)
- 심화 [A08 Service 타입과 엔드포인트 확인](../mock_exam_a/q08_service_types_endpoints/question.md)
