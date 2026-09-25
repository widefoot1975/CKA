# mock_exam_d

| 항목 | 내용 |
|---|---|
| 출처 | 자체 출제 (CKA 커리큘럼 v1.35 비중 반영, 기본 난이도) |
| 성격 | 전 범위 독립 모의고사 — 기본 난이도. a/b/c보다 단계가 적고 한 문제에 한 가지 개념만 묻습니다 |
| 응시일 |  |
| 제한 시간 | 120분 (목표 시간 합계 110분, 여유 10분) |
| 실제 소요 |  |
| 점수 | / 100 (합격선 66) |

문제는 영문(`question.md`), 풀이는 한글(`solution.md`)입니다. `solution.md` 맨 앞에 한글 해석이 있으니, 풀이를 보기 전에 영문을 제대로 읽었는지 먼저 대조하세요.

각 문제는 메타 표의 `Host` 로 `ssh` 해서 풉니다. 실제 시험에서는 지정 호스트가 아닌 곳에서 작업하면 0점이고, 문제를 마치면 `exit` 로 베이스 터미널에 돌아온 뒤 다음 문제의 호스트로 들어갑니다.

## 문항

`목표`는 배점에 비례해 배분한 **시간 예산**입니다 (일반 문항 배점×1분, Troubleshooting 배점×1.33분). 실제로 걸린 시간은 `실제` 칸과 각 `question.md` 의 `Actual time` 에 적으세요. 예산을 넘기는 문항이 어디인지가 다음 공부 주제입니다.

| # | 문제 | 도메인 | 배점 | 목표 | 실제 | 결과 | 링크 |
|---|---|---|---|---|---|---|---|
| 01 | Install and upgrade a Helm release | Cluster Arch | 7 | 7분 |  | ☐ | [Q](q01_helm_install_pinned_chart/question.md) · [S](q01_helm_install_pinned_chart/solution.md) |
| 02 | Read-only pod access for a ServiceAccount | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q02_rbac_pod_reader_serviceaccount/question.md) · [S](q02_rbac_pod_reader_serviceaccount/solution.md) |
| 03 | Explore installed CRDs with kubectl | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q03_crd_explore_explain/question.md) · [S](q03_crd_explore_explain/solution.md) |
| 04 | Check and renew a control plane certificate | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q04_kubeadm_cert_renewal/question.md) · [S](q04_kubeadm_cert_renewal/solution.md) |
| 05 | Scale, update and roll back a Deployment | Workloads | 5 | 5분 |  | ☐ | [Q](q05_deployment_scale_rollout_undo/question.md) · [S](q05_deployment_scale_rollout_undo/solution.md) |
| 06 | Inject a ConfigMap as an env var and a file | Workloads | 5 | 5분 |  | ☐ | [Q](q06_configmap_env_and_volume/question.md) · [S](q06_configmap_env_and_volume/solution.md) |
| 07 | Dedicate a node with a taint and a toleration | Workloads | 5 | 5분 |  | ☐ | [Q](q07_taint_toleration_dedicated_node/question.md) · [S](q07_taint_toleration_dedicated_node/solution.md) |
| 08 | Expose a Service through the Gateway API | Networking | 7 | 7분 |  | ☐ | [Q](q08_gateway_httproute_basic/question.md) · [S](q08_gateway_httproute_basic/solution.md) |
| 09 | Publish a container port with a NodePort Service | Networking | 7 | 7분 |  | ☐ | [Q](q09_nodeport_expose_container_port/question.md) · [S](q09_nodeport_expose_container_port/solution.md) |
| 10 | Allow traffic to a backend from one frontend only | Networking | 6 | 6분 |  | ☐ | [Q](q10_networkpolicy_allow_from_label/question.md) · [S](q10_networkpolicy_allow_from_label/solution.md) |
| 11 | Create a default StorageClass | Storage | 5 | 5분 |  | ☐ | [Q](q11_storageclass_default_wffc/question.md) · [S](q11_storageclass_default_wffc/solution.md) |
| 12 | Claim storage and mount it in a Pod | Storage | 5 | 5분 |  | ☐ | [Q](q12_pvc_pod_mount/question.md) · [S](q12_pvc_pod_mount/solution.md) |
| 13 | Bring a NotReady node back | Troubleshooting | 7 | 9분 |  | ☐ | [Q](q13_node_kubelet_stopped/question.md) · [S](q13_node_kubelet_stopped/solution.md) |
| 14 | Pods stay Pending because the scheduler is broken | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q14_scheduler_static_pod_image/question.md) · [S](q14_scheduler_static_pod_image/solution.md) |
| 15 | A Service with no endpoints | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q15_service_selector_mismatch/question.md) · [S](q15_service_selector_mismatch/solution.md) |
| 16 | Read logs from an app and its sidecar | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q16_sidecar_container_logs/question.md) · [S](q16_sidecar_container_logs/solution.md) |
| 17 | Find the heaviest Pod with kubectl top | Troubleshooting | 5 | 7분 |  | ☐ | [Q](q17_top_pod_cpu/question.md) · [S](q17_top_pod_cpu/solution.md) |
| | **합계** | | **100** | **110분** |  | | |

## 도메인별 실점

| 도메인 | 비중 | 배점 합 | 목표 시간 | 획득 | 손실 |
|---|---|---|---|---|---|
| Troubleshooting | 30% | 30 | 40분 |  |  |
| Cluster Architecture, Installation & Configuration | 25% | 25 | 25분 |  |  |
| Services & Networking | 20% | 20 | 20분 |  |  |
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
