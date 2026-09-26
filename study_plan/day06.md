# 6일차 (D-5) — NetworkPolicy · DNS · 스토리지

[← 5일차](day05.md) · [계획 전체](README.md) · [7일차 →](day07.md)

## 오늘의 목표

네트워크의 나머지(NetworkPolicy, CoreDNS)와 **Storage(10%) 전체**를 끝냅니다. 오늘까지 마치면 트러블슈팅을 뺀 모든 도메인을 한 바퀴 돈 것입니다.

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:15 | [exam_guide.md](../exam_guide.md) §6.3 NetworkPolicy, §6.6 CoreDNS, §7 Storage |
| 0:15 – 0:42 | 아래 문제 5개 풀기 |
| 0:42 – 0:57 | `solution.md` 와 대조, 오답 원인 기록 |
| 0:57 – 1:00 | 도메인별 자신감 표(루트 README)를 지금 기준으로 한 번 채워 보기 |

## 풀 문제

| 문제 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|
| D10 | 한 frontend에서만 backend로 허용 | 6 | 6분 | [Q](../mock_exam_d/q10_networkpolicy_allow_from_label/question.md) · [S](../mock_exam_d/q10_networkpolicy_allow_from_label/solution.md) ☐ |
| F10 | CoreDNS에 정적 DNS 레코드 추가 | 6 | 6분 | [Q](../mock_exam_f/q10_coredns_hosts_entry/question.md) · [S](../mock_exam_f/q10_coredns_hosts_entry/solution.md) ☐ |
| D11 | 기본 StorageClass 만들기 | 5 | 5분 | [Q](../mock_exam_d/q11_storageclass_default_wffc/question.md) · [S](../mock_exam_d/q11_storageclass_default_wffc/solution.md) ☐ |
| D12 | PVC를 만들어 파드에 마운트 | 5 | 5분 | [Q](../mock_exam_d/q12_pvc_pod_mount/question.md) · [S](../mock_exam_d/q12_pvc_pod_mount/solution.md) ☐ |
| E11 | Retain된 볼륨을 새 Deployment에 다시 연결 | 5 | 5분 | [Q](../mock_exam_e/q11_retained_pv_reuse/question.md) · [S](../mock_exam_e/q11_retained_pv_reuse/solution.md) ☐ |

합계 27점, 목표 27분.

## 꼭 잡을 것

```bash
kubectl -n kube-system edit cm coredns          # Corefile 수정 후
kubectl -n kube-system rollout restart deploy coredns
kubectl run t --rm -it --image=busybox:1.36 --restart=Never -- nslookup <svc>.<ns>.svc.cluster.local

kubectl patch storageclass <sc> -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
kubectl patch pv <pv> --type json -p '[{"op":"remove","path":"/spec/claimRef"}]'
```

- NetworkPolicy: 같은 `-` 항목 안에 있으면 AND, 따로 있으면 OR입니다. egress를 막으면 DNS(53번)도 막힙니다 (함정 31).
- Service FQDN은 `<svc>.<ns>.svc.cluster.local` 입니다. `svc` 를 빠뜨리기 쉽습니다 (함정 35).
- `storageClassName` 을 생략하면 기본 클래스, `""` 로 쓰면 클래스 없음입니다 (함정 36).
- `Retain` PV는 `Released` 상태가 되며, `claimRef` 를 지워야 다시 쓸 수 있습니다 (함정 37).
- `WaitForFirstConsumer` 클래스의 PVC가 `Pending` 인 것은 정상입니다 (함정 38).

## 여유가 있으면

- 기본 [F09 가장 좁은 NetworkPolicy 고르기](../mock_exam_f/q09_networkpolicy_least_permissive/question.md)
- 기본 [F12 Projected volume](../mock_exam_f/q12_projected_volume/question.md)
- 심화 [B09 ingress·egress 동시 제한](../mock_exam_b/q09_networkpolicy_ingress_egress/question.md)
