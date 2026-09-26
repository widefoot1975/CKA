# 8일차 (D-3) — 트러블슈팅 ② 파드 · 서비스 · 로그 · 모니터링

[← 7일차](day07.md) · [계획 전체](README.md) · [9일차 →](day09.md)

## 오늘의 목표

Troubleshooting(30%)의 후반부입니다. 파드 상태별 원인, 엔드포인트가 없는 Service, **컨테이너 출력 스트림**, **리소스 사용량 모니터링**을 다룹니다. 마지막 두 항목은 2025년 개정으로 들어온 것입니다.

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:12 | [exam_guide.md](../exam_guide.md) §8.4 파드 상태별 원인, §8.5 서비스·네트워크, §8.6 리소스 사용량 모니터링, §8.7 컨테이너 출력 스트림 |
| 0:12 – 0:43 | 아래 문제 4개 풀기 |
| 0:43 – 0:57 | `solution.md` 와 대조, 오답 원인 기록 |
| 0:57 – 1:00 | 루트 README **반복 오답 목록** 갱신 |

## 풀 문제

| 문제 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|
| E15 | CrashLoop에 빠진 Deployment 고치기 | 6 | 8분 | [Q](../mock_exam_e/q15_crashloop_wrong_command/question.md) · [S](../mock_exam_e/q15_crashloop_wrong_command/solution.md) ☐ |
| D15 | 엔드포인트가 없는 Service | 6 | 8분 | [Q](../mock_exam_d/q15_service_selector_mismatch/question.md) · [S](../mock_exam_d/q15_service_selector_mismatch/solution.md) ☐ |
| D16 | 앱과 사이드카의 로그 읽기 | 6 | 8분 | [Q](../mock_exam_d/q16_sidecar_container_logs/question.md) · [S](../mock_exam_d/q16_sidecar_container_logs/solution.md) ☐ |
| D17 | kubectl top으로 가장 무거운 파드 찾기 | 5 | 7분 | [Q](../mock_exam_d/q17_top_pod_cpu/question.md) · [S](../mock_exam_d/q17_top_pod_cpu/solution.md) ☐ |

합계 23점, 목표 31분.

## 꼭 잡을 것

```bash
kubectl describe pod <pod>                      # Events, Last State, Exit Code
kubectl logs <pod> --previous                   # 죽기 전 인스턴스의 로그
kubectl logs <pod> -c <container>
kubectl logs <pod> --all-containers --prefix

kubectl get pod --show-labels
kubectl get svc <svc> -o jsonpath='{.spec.selector}'
kubectl get endpointslice -l kubernetes.io/service-name=<svc>

kubectl top pod -A --sort-by=cpu
kubectl top pod <pod> --containers
kubectl top node
```

- 파드가 계속 재시작하면 현재 로그는 비어 있을 수 있습니다. `--previous` 로 죽기 직전 로그를 봅니다 (함정 39).
- `-c` 를 빠뜨리면 **아무 경고 없이** 첫 컨테이너 로그가 나옵니다. `-l` 로 여러 파드를 보면 기본 10줄만 나옵니다 (함정 39).
- Service에 엔드포인트가 없으면 먼저 selector와 파드 라벨을 비교합니다. 엔드포인트가 있는데 연결이 거부되면 `targetPort` 를 봅니다 (함정 28).
- 결과를 파일로 제출하는 문제는 **경로와 형식**(이름만인지, 네임스페이스 포함인지)을 문제 그대로 맞춥니다.

## 여유가 있으면

- 기본 [E16 클러스터 DNS 장애](../mock_exam_e/q16_coredns_scaled_to_zero/question.md) — 9일차 모의고사에 들어가니 오늘은 건너뛰어도 됩니다
- 기본 [F16 파드의 모든 컨테이너 로그 수집](../mock_exam_f/q16_multicontainer_logs_prefix/question.md)
- 심화 [C14 OOMKilled 컨테이너 분석](../mock_exam_c/q14_oomkilled_resource_analysis/question.md)
