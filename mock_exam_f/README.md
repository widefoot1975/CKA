# mock_exam_f

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
| 01 | Render and install a chart without its CRDs | Cluster Arch | 7 | 7분 |  | ☐ | [Q](q01_helm_template_without_crds/question.md) · [S](q01_helm_template_without_crds/solution.md) |
| 02 | Reuse a ClusterRole inside one namespace | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q02_clusterrole_rolebinding_scope/question.md) · [S](q02_clusterrole_rolebinding_scope/solution.md) |
| 03 | Upgrade one worker node with kubeadm | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q03_kubeadm_upgrade_worker/question.md) · [S](q03_kubeadm_upgrade_worker/solution.md) |
| 04 | Identify the CRI, CNI and CSI in use | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q04_extension_interfaces_inventory/question.md) · [S](q04_extension_interfaces_inventory/solution.md) |
| 05 | Create a PriorityClass relative to existing ones | Workloads | 5 | 5분 |  | ☐ | [Q](q05_priorityclass_derived_value/question.md) · [S](q05_priorityclass_derived_value/solution.md) |
| 06 | Update configuration and lock it | Workloads | 5 | 5분 |  | ☐ | [Q](q06_configmap_update_immutable/question.md) · [S](q06_configmap_update_immutable/solution.md) |
| 07 | Schedule and trigger a CronJob | Workloads | 5 | 5분 |  | ☐ | [Q](q07_cronjob_manual_trigger/question.md) · [S](q07_cronjob_manual_trigger/solution.md) |
| 08 | Move an HTTP Ingress to an HTTPRoute | Networking | 7 | 7분 |  | ☐ | [Q](q08_ingress_to_httproute_simple/question.md) · [S](q08_ingress_to_httproute_simple/solution.md) |
| 09 | Choose the least permissive NetworkPolicy | Networking | 7 | 7분 |  | ☐ | [Q](q09_networkpolicy_least_permissive/question.md) · [S](q09_networkpolicy_least_permissive/solution.md) |
| 10 | Add a static DNS record with CoreDNS | Networking | 6 | 6분 |  | ☐ | [Q](q10_coredns_hosts_entry/question.md) · [S](q10_coredns_hosts_entry/solution.md) |
| 11 | Protect a dynamically provisioned volume | Storage | 5 | 5분 |  | ☐ | [Q](q11_pv_reclaim_policy_patch/question.md) · [S](q11_pv_reclaim_policy_patch/solution.md) |
| 12 | Combine a Secret, a ConfigMap and pod labels in one volume | Storage | 5 | 5분 |  | ☐ | [Q](q12_projected_volume/question.md) · [S](q12_projected_volume/solution.md) |
| 13 | Node NotReady after a kubelet config change | Troubleshooting | 7 | 9분 |  | ☐ | [Q](q13_kubelet_wrong_runtime_endpoint/question.md) · [S](q13_kubelet_wrong_runtime_endpoint/solution.md) |
| 14 | kubectl cannot reach the API server | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q14_kubeconfig_wrong_port/question.md) · [S](q14_kubeconfig_wrong_port/solution.md) |
| 15 | Endpoints exist but connections are refused | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q15_service_targetport_mismatch/question.md) · [S](q15_service_targetport_mismatch/solution.md) |
| 16 | Collect logs from every container of a Pod | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q16_multicontainer_logs_prefix/question.md) · [S](q16_multicontainer_logs_prefix/solution.md) |
| 17 | Give a running Pod more memory without restarting it | Troubleshooting | 5 | 7분 |  | ☐ | [Q](q17_resize_pod_in_place/question.md) · [S](q17_resize_pod_in_place/solution.md) |
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
