# mock_exam_b

| 항목 | 내용 |
|---|---|
| 출처 | 자체 출제 (CKA 커리큘럼 v1.35 비중 반영) |
| 성격 | 전 범위 독립 모의고사 — 다른 회차와 문제가 겹치지 않습니다 |
| 응시일 |  |
| 제한 시간 | 120분 (목표 시간 합계 110분, 여유 10분) |
| 실제 소요 |  |
| 점수 | / 100 (합격선 66) |

문제는 영문(`question.md`), 풀이는 한글(`solution.md`)입니다. `solution.md` 맨 앞에 한글 해석이 있으니, 풀이를 보기 전에 영문을 제대로 읽었는지 먼저 대조하세요.

각 문제의 컨텍스트 전환(`kubectl config use-context`)을 빼먹으면 실제 시험에서는 0점입니다.

## 문항

`목표`는 배점에 비례해 배분한 **시간 예산**입니다 (일반 문항 배점×1분, Troubleshooting 배점×1.33분). 실제로 걸린 시간은 `실제` 칸과 각 `question.md` 의 `Actual time` 에 적으세요. 예산을 넘기는 문항이 어디인지가 다음 공부 주제입니다.

| # | 문제 | 도메인 | 배점 | 목표 | 실제 | 결과 | 링크 |
|---|---|---|---|---|---|---|---|
| 01 | Verify and operate a highly-available control plane | Cluster Arch | 7 | 7분 |  | ☐ | [Q](q01_ha_control_plane/question.md) · [S](q01_ha_control_plane/solution.md) |
| 02 | Prepare a node for joining a cluster | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q02_node_prerequisites_containerd/question.md) · [S](q02_node_prerequisites_containerd/solution.md) |
| 03 | Install a CRD and create a custom resource | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q03_crd_custom_resource/question.md) · [S](q03_crd_custom_resource/solution.md) |
| 04 | Inspect the container runtime with crictl | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q04_crictl_container_runtime/question.md) · [S](q04_crictl_container_runtime/solution.md) |
| 05 | Configure workload autoscaling with an HPA | Workloads | 5 | 5분 |  | ☐ | [Q](q05_hpa_workload_autoscaling/question.md) · [S](q05_hpa_workload_autoscaling/solution.md) |
| 06 | Constrain a namespace with ResourceQuota and LimitRange | Workloads | 5 | 5분 |  | ☐ | [Q](q06_resourcequota_limitrange/question.md) · [S](q06_resourcequota_limitrange/solution.md) |
| 07 | Pod priority and preemption | Workloads | 5 | 5분 |  | ☐ | [Q](q07_priorityclass_preemption/question.md) · [S](q07_priorityclass_preemption/solution.md) |
| 08 | Expose a service with the Gateway API | Networking | 7 | 7분 |  | ☐ | [Q](q08_gateway_api_httproute/question.md) · [S](q08_gateway_api_httproute/solution.md) |
| 09 | Restrict both ingress and egress with NetworkPolicy | Networking | 7 | 7분 |  | ☐ | [Q](q09_networkpolicy_ingress_egress/question.md) · [S](q09_networkpolicy_ingress_egress/solution.md) |
| 10 | Verify pod-to-pod connectivity across namespaces | Networking | 6 | 6분 |  | ☐ | [Q](q10_pod_connectivity_check/question.md) · [S](q10_pod_connectivity_check/solution.md) |
| 11 | Dynamic provisioning and volume expansion | Storage | 5 | 5분 |  | ☐ | [Q](q11_storageclass_dynamic_expand/question.md) · [S](q11_storageclass_dynamic_expand/solution.md) |
| 12 | Inspect CSI drivers and use a block volumeMode | Storage | 5 | 5분 |  | ☐ | [Q](q12_csi_driver_volumemode/question.md) · [S](q12_csi_driver_volumemode/solution.md) |
| 13 | Restore metrics-server and analyse resource usage | Troubleshooting | 7 | 9분 |  | ☐ | [Q](q13_metrics_server_resource_usage/question.md) · [S](q13_metrics_server_resource_usage/solution.md) |
| 14 | Gateway accepts traffic but nothing reaches the backend | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q14_gateway_traffic_not_routed/question.md) · [S](q14_gateway_traffic_not_routed/solution.md) |
| 15 | Pods stuck in ContainerCreating after a CNI failure | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q15_cni_pod_containercreating/question.md) · [S](q15_cni_pod_containercreating/solution.md) |
| 16 | A control plane component is not running | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q16_control_plane_component_down/question.md) · [S](q16_control_plane_component_down/solution.md) |
| 17 | Node lost after kubelet client certificate expiry | Troubleshooting | 5 | 7분 |  | ☐ | [Q](q17_kubelet_certificate_expired/question.md) · [S](q17_kubelet_certificate_expired/solution.md) |
| | **합계** | | **100** | **110분** |  | | |

## 도메인별 실점

| 도메인 | 비중 | 배점 합 | 목표 시간 | 획득 | 손실 |
|---|---|---|---|---|---|
| Troubleshooting | 30% | 30 | 40분 |  |  |
| Cluster Architecture, Installation & Configuration | 25% | 25 | 25분 |  |  |
| Servicing & Networking | 20% | 20 | 20분 |  |  |
| Workloads & Scheduling | 15% | 15 | 15분 |  |  |
| Storage | 10% | 10 | 10분 |  |  |

## 회고

**잘한 것**

-

**놓친 것**

-

**시간을 많이 쓴 문항** (목표 대비 초과)

-

**다음 회차까지 할 것**

- [ ]
