# 2일차 (D-9) — RBAC · Helm · Kustomize · CRD

[← 1일차](day01.md) · [계획 전체](README.md) · [3일차 →](day03.md)

## 오늘의 목표

Cluster Architecture(25%) 중 **클러스터 안에서 도구로 해결하는 항목**을 끝냅니다. Helm·Kustomize·CRD는 2025년 개정으로 들어온 항목이라 옛 자료에는 없습니다.

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:15 | [exam_guide.md](../exam_guide.md) §4.1 RBAC, §4.5 Helm, §4.6 Kustomize, §4.8 CRD와 operator |
| 0:15 – 0:40 | 아래 문제 4개 풀기 |
| 0:40 – 0:55 | `solution.md` 와 대조, 오답 원인 기록 |
| 0:55 – 1:00 | [cheatsheet.md](../cheatsheet.md) §7 Helm, §8 Kustomize 훑기 |

## 풀 문제

| 문제 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|
| D01 | 버전을 고정해 Helm 릴리스 설치·업그레이드 | 7 | 7분 | [Q](../mock_exam_d/q01_helm_install_pinned_chart/question.md) · [S](../mock_exam_d/q01_helm_install_pinned_chart/solution.md) ☐ |
| D02 | ServiceAccount에 파드 읽기 권한 | 6 | 6분 | [Q](../mock_exam_d/q02_rbac_pod_reader_serviceaccount/question.md) · [S](../mock_exam_d/q02_rbac_pod_reader_serviceaccount/solution.md) ☐ |
| E02 | Kustomize overlay 적용 | 6 | 6분 | [Q](../mock_exam_e/q02_kustomize_overlay_basic/question.md) · [S](../mock_exam_e/q02_kustomize_overlay_basic/solution.md) ☐ |
| D03 | 설치된 CRD를 kubectl로 탐색 | 6 | 6분 | [Q](../mock_exam_d/q03_crd_explore_explain/question.md) · [S](../mock_exam_d/q03_crd_explore_explain/solution.md) ☐ |

합계 25점, 목표 25분.

## 꼭 잡을 것

```bash
kubectl create role pod-reader --verb=get,list,watch --resource=pods -n dev
kubectl create rolebinding pod-reader --role=pod-reader --serviceaccount=dev:app-sa -n dev
kubectl auth can-i list pods --as=system:serviceaccount:dev:app-sa -n dev

helm repo add <repo> <url> && helm repo update
helm install <릴리스> <repo>/<차트> --version <버전> -n <ns> --create-namespace
helm upgrade <릴리스> <repo>/<차트> --version <버전> --reuse-values -n <ns>
helm history <릴리스> -n <ns>

kubectl kustomize overlays/prod        # 적용 전에 결과 확인
kubectl apply -k overlays/prod

kubectl api-resources --api-group=<group>
kubectl explain <kind>.spec --recursive | head
```

- RBAC `apiGroups`: deployments는 `apps`, pods는 `""`, CRD는 그 CRD의 group (함정 7).
- 서브리소스 권한 확인은 `--subresource=scale` 로 합니다 (함정 6).
- Helm `upgrade` 에 `--reuse-values` 를 빠뜨리거나 `--version` 을 고정하지 않으면 감점입니다 (함정 14).
- Kustomize의 `replicas`·`patches` 는 **접두사가 붙기 전** 이름으로 씁니다 (함정 15).
- CRD 이름은 `<plural>.<group>` 이고, CRD를 지우면 그 인스턴스가 모두 지워집니다 (함정 16).

## 여유가 있으면

- 기본 [E03 CRD 설치와 커스텀 리소스 생성](../mock_exam_e/q03_crd_install_custom_resource/question.md)
- 심화 [A01 네임스페이스 RBAC](../mock_exam_a/q01_rbac_role_binding/question.md)
- 심화 [A03 Helm 릴리스 수명주기](../mock_exam_a/q03_helm_release_lifecycle/question.md)
