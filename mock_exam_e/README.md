# mock_exam_e

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
| 01 | Install cri-dockerd and set kernel parameters | Cluster Arch | 7 | 7분 |  | ☐ | [Q](q01_cri_dockerd_node_prep/question.md) · [S](q01_cri_dockerd_node_prep/solution.md) |
| 02 | Apply a Kustomize overlay | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q02_kustomize_overlay_basic/question.md) · [S](q02_kustomize_overlay_basic/solution.md) |
| 03 | Install a CRD and create a custom resource | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q03_crd_install_custom_resource/question.md) · [S](q03_crd_install_custom_resource/solution.md) |
| 04 | Inspect a highly-available control plane | Cluster Arch | 6 | 6분 |  | ☐ | [Q](q04_ha_control_plane_inspect/question.md) · [S](q04_ha_control_plane_inspect/solution.md) |
| 05 | Autoscale a Deployment with an HPA | Workloads | 5 | 5분 |  | ☐ | [Q](q05_hpa_behavior/question.md) · [S](q05_hpa_behavior/solution.md) |
| 06 | Set resources on every container, including init | Workloads | 5 | 5분 |  | ☐ | [Q](q06_resource_requests_all_containers/question.md) · [S](q06_resource_requests_all_containers/solution.md) |
| 07 | Add a native sidecar to an existing Deployment | Workloads | 5 | 5분 |  | ☐ | [Q](q07_native_sidecar_log_shipper/question.md) · [S](q07_native_sidecar_log_shipper/solution.md) |
| 08 | Route two paths with one HTTPRoute | Networking | 7 | 7분 |  | ☐ | [Q](q08_httproute_path_routing/question.md) · [S](q08_httproute_path_routing/solution.md) |
| 09 | Publish a Service with an Ingress | Networking | 7 | 7분 |  | ☐ | [Q](q09_ingress_path_basic/question.md) · [S](q09_ingress_path_basic/solution.md) |
| 10 | Point a Service at a named container port | Networking | 6 | 6분 |  | ☐ | [Q](q10_service_named_targetport/question.md) · [S](q10_service_named_targetport/solution.md) |
| 11 | Reattach a retained volume to a new Deployment | Storage | 5 | 5분 |  | ☐ | [Q](q11_retained_pv_reuse/question.md) · [S](q11_retained_pv_reuse/solution.md) |
| 12 | Share a scratch volume between containers | Storage | 5 | 5분 |  | ☐ | [Q](q12_emptydir_memory_sizelimit/question.md) · [S](q12_emptydir_memory_sizelimit/solution.md) |
| 13 | API server down after a machine migration | Troubleshooting | 7 | 9분 |  | ☐ | [Q](q13_apiserver_wrong_etcd_endpoint/question.md) · [S](q13_apiserver_wrong_etcd_endpoint/solution.md) |
| 14 | Node NotReady because the container runtime is down | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q14_node_containerd_stopped/question.md) · [S](q14_node_containerd_stopped/solution.md) |
| 15 | Fix a crash-looping Deployment | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q15_crashloop_wrong_command/question.md) · [S](q15_crashloop_wrong_command/solution.md) |
| 16 | Cluster DNS stopped working | Troubleshooting | 6 | 8분 |  | ☐ | [Q](q16_coredns_scaled_to_zero/question.md) · [S](q16_coredns_scaled_to_zero/solution.md) |
| 17 | Analyse resource usage per node and container | Troubleshooting | 5 | 7분 |  | ☐ | [Q](q17_top_node_and_containers/question.md) · [S](q17_top_node_and_containers/solution.md) |
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
