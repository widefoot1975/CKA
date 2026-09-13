# mock_exam_a

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
| 01 | Namespaced RBAC for a deployment operator | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q01_rbac_role_binding/question.md) · [S](q01_rbac_role_binding/solution.md) |
| 02 | Upgrade the cluster lifecycle with kubeadm | Cluster Arch | 7 | 7분 |  | ☐ | [Q](q02_kubeadm_cluster_upgrade/question.md) · [S](q02_kubeadm_cluster_upgrade/solution.md) |
| 03 | Manage a cluster component with Helm | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q03_helm_release_lifecycle/question.md) · [S](q03_helm_release_lifecycle/solution.md) |
| 04 | Create a kubeconfig for a certificate-based user | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q04_kubeconfig_certificate_management/question.md) · [S](q04_kubeconfig_certificate_management/solution.md) |
| 05 | Rolling update, pause and roll back a Deployment | Workloads | 5 | 5분 |  | ☐ | [Q](q05_deployment_rollout_rollback/question.md) · [S](q05_deployment_rollout_rollback/solution.md) |
| 06 | Configure an application with a ConfigMap and Secret | Workloads | 5 | 5분 |  | ☐ | [Q](q06_configmap_secret_injection/question.md) · [S](q06_configmap_secret_injection/solution.md) |
| 07 | Place pods with taints, tolerations and node affinity | Workloads | 5 | 5분 |  | ☐ | [Q](q07_taint_toleration_affinity/question.md) · [S](q07_taint_toleration_affinity/solution.md) |
| 08 | Service types and endpoint inspection | Networking | 7 | 7분 |  | ☐ | [Q](q08_service_types_endpoints/question.md) · [S](q08_service_types_endpoints/solution.md) |
| 09 | Route traffic with an Ingress | Networking | 7 | 7분 |  | ☐ | [Q](q09_ingress_path_routing/question.md) · [S](q09_ingress_path_routing/solution.md) |
| 10 | Service discovery with CoreDNS | Networking | 6 | 6분 |  | ☐ | [Q](q10_coredns_service_discovery/question.md) · [S](q10_coredns_service_discovery/solution.md) |
| 11 | Static PersistentVolume provisioning | Storage | 5 | 5분 |  | ☐ | [Q](q11_pv_pvc_static_provisioning/question.md) · [S](q11_pv_pvc_static_provisioning/solution.md) |
| 12 | Access modes and reclaim policy | Storage | 5 | 5분 |  | ☐ | [Q](q12_access_modes_reclaim_policy/question.md) · [S](q12_access_modes_reclaim_policy/solution.md) |
| 13 | Recover a NotReady node | Troubleshooting | 7 | 9분 |  | ☐ | [Q](q13_node_notready_kubelet/question.md) · [S](q13_node_notready_kubelet/solution.md) |
| 14 | Diagnose a CrashLoopBackOff pod | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q14_pod_crashloopbackoff/question.md) · [S](q14_pod_crashloopbackoff/solution.md) |
| 15 | A Service with no endpoints | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q15_service_no_endpoints/question.md) · [S](q15_service_no_endpoints/solution.md) |
| 16 | Read and evaluate container output streams | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q16_container_log_streams/question.md) · [S](q16_container_log_streams/solution.md) |
| 17 | Control plane down from a static pod manifest error | Troubleshooting | 5 | 7분 |  | ☐ | [Q](q17_static_pod_manifest_error/question.md) · [S](q17_static_pod_manifest_error/solution.md) |
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
