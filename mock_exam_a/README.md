# mock_exam_a

| 항목 | 내용 |
|---|---|
| 출처 | 자체 출제 (CKA 커리큘럼 v1.35 비중 반영) |
| 응시일 |  |
| 제한 시간 | 120분 |
| 실제 소요 |  |
| 점수 | / 100 (합격선 66) |

**문제는 영문(`question.md`), 풀이는 한글(`solution.md`)로 분리되어 있습니다.** 실제 시험이 영문이므로 문제를 영문으로 읽는 연습을 겸합니다. 먼저 `question.md`만 열고 풀어 본 뒤 `solution.md`를 확인하세요.

각 문제의 컨텍스트 전환(`kubectl config use-context`)을 빼먹으면 실제 시험에서는 0점입니다.

## 문항

| # | 문제 | 도메인 | 배점 | 결과 | 문제 | 풀이 |
|---|---|---|---|---|---|---|
| 01 | Least-privilege Role for a ServiceAccount | Cluster Arch | 6 | ☐ | [question](q01_rbac_serviceaccount/question.md) | [solution](q01_rbac_serviceaccount/solution.md) |
| 02 | Back up and restore etcd from a snapshot | Cluster Arch | 8 | ☐ | [question](q02_etcd_backup_restore/question.md) | [solution](q02_etcd_backup_restore/solution.md) |
| 03 | Upgrade a kubeadm cluster | Cluster Arch | 6 | ☐ | [question](q03_kubeadm_upgrade/question.md) | [solution](q03_kubeadm_upgrade/solution.md) |
| 04 | Node maintenance with drain and uncordon | Cluster Arch | 5 | ☐ | [question](q04_node_drain_maintenance/question.md) | [solution](q04_node_drain_maintenance/solution.md) |
| 05 | Deployment rolling update and rollback | Workloads | 5 | ☐ | [question](q05_deployment_rollout_rollback/question.md) | [solution](q05_deployment_rollout_rollback/solution.md) |
| 06 | Scheduling with taints, tolerations and node affinity | Workloads | 5 | ☐ | [question](q06_scheduling_affinity_taint/question.md) | [solution](q06_scheduling_affinity_taint/solution.md) |
| 07 | Inject a ConfigMap and Secret as env vars and a volume | Workloads | 5 | ☐ | [question](q07_configmap_secret_injection/question.md) | [solution](q07_configmap_secret_injection/solution.md) |
| 08 | Expose a Deployment through a NodePort Service | Networking | 7 | ☐ | [question](q08_service_nodeport/question.md) | [solution](q08_service_nodeport/solution.md) |
| 09 | Path-based routing with an Ingress | Networking | 7 | ☐ | [question](q09_ingress_path_routing/question.md) | [solution](q09_ingress_path_routing/solution.md) |
| 10 | Default-deny NetworkPolicy with a selective allow | Networking | 6 | ☐ | [question](q10_networkpolicy_default_deny/question.md) | [solution](q10_networkpolicy_default_deny/solution.md) |
| 11 | Static PV/PVC provisioning and mounting | Storage | 5 | ☐ | [question](q11_pv_pvc_static/question.md) | [solution](q11_pv_pvc_static/solution.md) |
| 12 | Dynamic provisioning and PVC expansion | Storage | 5 | ☐ | [question](q12_storageclass_dynamic_expand/question.md) | [solution](q12_storageclass_dynamic_expand/solution.md) |
| 13 | Recover a NotReady node | Troubleshooting | 7 | ☐ | [question](q13_node_notready_kubelet/question.md) | [solution](q13_node_notready_kubelet/solution.md) |
| 14 | Diagnose a CrashLoopBackOff pod | Troubleshooting | 7 | ☐ | [question](q14_pod_crashloopbackoff/question.md) | [solution](q14_pod_crashloopbackoff/solution.md) |
| 15 | A Service with no Endpoints | Troubleshooting | 6 | ☐ | [question](q15_service_no_endpoints/question.md) | [solution](q15_service_no_endpoints/solution.md) |
| 16 | Control plane down due to a static pod manifest error | Troubleshooting | 5 | ☐ | [question](q16_static_pod_manifest_error/question.md) | [solution](q16_static_pod_manifest_error/solution.md) |
| 17 | CoreDNS name resolution failure | Troubleshooting | 5 | ☐ | [question](q17_coredns_resolution_failure/question.md) | [solution](q17_coredns_resolution_failure/solution.md) |

## 도메인별 실점

| 도메인 | 비중 | 배점 합 | 획득 | 손실 |
|---|---|---|---|---|
| Troubleshooting | 30% | 30 |  |  |
| Cluster Architecture, Installation & Configuration | 25% | 25 |  |  |
| Services & Networking | 20% | 20 |  |  |
| Workloads & Scheduling | 15% | 15 |  |  |
| Storage | 10% | 10 |  |  |

## 회고

**잘한 것**

-

**놓친 것**

-

**다음 회차까지 할 것**

- [ ]
