# 5일차 (D-6) — Gateway API · Ingress

[← 4일차](day04.md) · [계획 전체](README.md) · [6일차 →](day06.md)

## 오늘의 목표

Services & Networking(20%) 중 **클러스터 밖에서 들어오는 트래픽**을 다룹니다. Ingress NGINX가 2026년 3월에 은퇴하면서 **Gateway API** 문제의 비중이 커졌습니다. Ingress를 HTTPRoute로 옮기는 유형까지 오늘 익힙니다.

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:15 | [exam_guide.md](../exam_guide.md) §6.2 Service, §6.4 Gateway API, §6.5 Ingress |
| 0:15 – 0:43 | 아래 문제 4개 풀기 |
| 0:43 – 0:57 | `solution.md` 와 대조, 오답 원인 기록 |
| 0:57 – 1:00 | [cheatsheet.md](../cheatsheet.md) §9 Gateway API 훑기 |

## 풀 문제

| 문제 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|
| D08 | Gateway API로 Service 공개 | 7 | 7분 | [Q](../mock_exam_d/q08_gateway_httproute_basic/question.md) · [S](../mock_exam_d/q08_gateway_httproute_basic/solution.md) ☐ |
| E08 | HTTPRoute 하나로 두 경로 라우팅 | 7 | 7분 | [Q](../mock_exam_e/q08_httproute_path_routing/question.md) · [S](../mock_exam_e/q08_httproute_path_routing/solution.md) ☐ |
| F08 | HTTP Ingress를 HTTPRoute로 이전 | 7 | 7분 | [Q](../mock_exam_f/q08_ingress_to_httproute_simple/question.md) · [S](../mock_exam_f/q08_ingress_to_httproute_simple/solution.md) ☐ |
| E09 | Ingress로 Service 공개 | 7 | 7분 | [Q](../mock_exam_e/q09_ingress_path_basic/question.md) · [S](../mock_exam_e/q09_ingress_path_basic/solution.md) ☐ |

합계 28점, 목표 28분.

## 꼭 잡을 것

```bash
kubectl get gatewayclass,gateway,httproute -A
kubectl explain httproute.spec.rules.matches
kubectl describe httproute <이름> -n <ns>      # Accepted / ResolvedRefs 조건 확인
kubectl create ingress web --class=nginx --rule="example.com/app*=web-svc:80" -n <ns> $do
```

- Gateway API는 명령형 생성이 없습니다. 시험 중에는 **gateway-api.sigs.k8s.io** 문서의 예제를 복사해 고칩니다.
- Gateway `allowedRoutes` 기본값은 `Same`(같은 네임스페이스)입니다. `backendRefs.port` 는 **Service 포트**, `sectionName` 은 listener **이름**입니다 (함정 32).
- Gateway 응답 코드: 404는 매칭되는 규칙이 없음, 500은 backendRef가 무효, 503은 endpoint가 없음 (함정 33).
- Ingress는 `pathType` 이 필수입니다. TLS Secret은 같은 네임스페이스에 있어야 하고 키는 `tls.crt`/`tls.key` 입니다 (함정 34).

## 여유가 있으면

- 심화 [B08 Gateway API로 서비스 공개](../mock_exam_b/q08_gateway_api_httproute/question.md)
- 심화 [C08 HTTPRoute 가중치 트래픽 분할](../mock_exam_c/q08_httproute_traffic_split/question.md)
- 심화 [C09 TLS Ingress를 Gateway API로 이전](../mock_exam_c/q09_ingress_to_gateway_migration/question.md)
