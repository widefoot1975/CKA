# mock_exam_c

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
| 01 | Join a new worker node to the cluster | Cluster Arch | 7 | 7분 |  | ☐ | [Q](q01_kubeadm_worker_join/question.md) · [S](q01_kubeadm_worker_join/solution.md) |
| 02 | Deploy an environment overlay with Kustomize | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q02_kustomize_overlay_deploy/question.md) · [S](q02_kustomize_overlay_deploy/solution.md) |
| 03 | Cluster-wide permissions with ClusterRole aggregation | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q03_clusterrole_aggregation/question.md) · [S](q03_clusterrole_aggregation/solution.md) |
| 04 | Install and configure an operator | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q04_operator_install_configure/question.md) · [S](q04_operator_install_configure/solution.md) |
| 05 | Self-healing with StatefulSet and DaemonSet | Workloads | 5 | 5분 |  | ☐ | [Q](q05_statefulset_daemonset_selfheal/question.md) · [S](q05_statefulset_daemonset_selfheal/solution.md) |
| 06 | Probes and a PodDisruptionBudget | Workloads | 5 | 5분 |  | ☐ | [Q](q06_probes_pod_disruption_budget/question.md) · [S](q06_probes_pod_disruption_budget/solution.md) |
| 07 | Run work with a Job and a CronJob | Workloads | 5 | 5분 |  | ☐ | [Q](q07_job_cronjob/question.md) · [S](q07_job_cronjob/solution.md) |
| 08 | Weighted traffic splitting with HTTPRoute | Networking | 7 | 7분 |  | ☐ | [Q](q08_httproute_traffic_split/question.md) · [S](q08_httproute_traffic_split/solution.md) |
| 09 | Terminate TLS at an Ingress | Networking | 6 | 6분 |  | ☐ | [Q](q09_ingress_tls_termination/question.md) · [S](q09_ingress_tls_termination/solution.md) |
| 10 | Headless Service and StatefulSet pod DNS | Networking | 7 | 7분 |  | ☐ | [Q](q10_headless_service_statefulset_dns/question.md) · [S](q10_headless_service_statefulset_dns/solution.md) |
| 11 | Per-replica storage with volumeClaimTemplates | Storage | 5 | 5분 |  | ☐ | [Q](q11_volumeclaimtemplates_statefulset/question.md) · [S](q11_volumeclaimtemplates_statefulset/solution.md) |
| 12 | Expand a PVC and observe reclaim behaviour | Storage | 5 | 5분 |  | ☐ | [Q](q12_pvc_expand_reclaim_behavior/question.md) · [S](q12_pvc_expand_reclaim_behavior/solution.md) |
| 13 | Cluster DNS resolution is failing | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q13_coredns_resolution_failure/question.md) · [S](q13_coredns_resolution_failure/solution.md) |
| 14 | A container is being OOMKilled | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q14_oomkilled_resource_analysis/question.md) · [S](q14_oomkilled_resource_analysis/solution.md) |
| 15 | Read output streams from a multi-container pod | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q15_multicontainer_sidecar_logs/question.md) · [S](q15_multicontainer_sidecar_logs/solution.md) |
| 16 | Pods evicted under node disk pressure | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q16_node_disk_pressure_eviction/question.md) · [S](q16_node_disk_pressure_eviction/solution.md) |
| 17 | Service traffic broken by kube-proxy | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q17_kubeproxy_service_networking/question.md) · [S](q17_kubeproxy_service_networking/solution.md) |
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
