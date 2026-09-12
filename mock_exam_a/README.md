# mock_exam_a

| 항목 | 내용 |
|---|---|
| 출처 | 자체 출제 (CKA 커리큘럼 v1.35 비중 반영) |
| 응시일 |  |
| 제한 시간 | 120분 |
| 실제 소요 |  |
| 점수 | / 100 (합격선 66) |

문제마다 `모범 풀이`는 접어 두었습니다. **먼저 직접 풀고 나서 펼치세요.**
각 문제 첫 줄의 컨텍스트 전환(`kubectl config use-context`)을 빼먹으면 실제 시험에서는 0점입니다.

## 문항

| # | 문제 | 도메인 | 배점 | 결과 | 폴더 |
|---|---|---|---|---|---|
| 01 | ServiceAccount에 최소 권한 Role 부여 | Cluster Arch | 6 | ☐ | [q01](q01_rbac_serviceaccount/) |
| 02 | etcd 스냅샷 백업 후 복구 | Cluster Arch | 8 | ☐ | [q02](q02_etcd_backup_restore/) |
| 03 | kubeadm 클러스터 업그레이드 | Cluster Arch | 6 | ☐ | [q03](q03_kubeadm_upgrade/) |
| 04 | 노드 유지보수 (drain / uncordon) | Cluster Arch | 5 | ☐ | [q04](q04_node_drain_maintenance/) |
| 05 | Deployment 롤링 업데이트와 롤백 | Workloads | 5 | ☐ | [q05](q05_deployment_rollout_rollback/) |
| 06 | taint/toleration + nodeAffinity 배치 | Workloads | 5 | ☐ | [q06](q06_scheduling_affinity_taint/) |
| 07 | ConfigMap·Secret을 env와 volume으로 주입 | Workloads | 5 | ☐ | [q07](q07_configmap_secret_injection/) |
| 08 | Service를 NodePort로 노출 | Networking | 7 | ☐ | [q08](q08_service_nodeport/) |
| 09 | Ingress 경로 기반 라우팅 | Networking | 7 | ☐ | [q09](q09_ingress_path_routing/) |
| 10 | NetworkPolicy default deny + 선택 허용 | Networking | 6 | ☐ | [q10](q10_networkpolicy_default_deny/) |
| 11 | PV/PVC 정적 프로비저닝과 마운트 | Storage | 5 | ☐ | [q11](q11_pv_pvc_static/) |
| 12 | StorageClass 동적 프로비저닝과 PVC 확장 | Storage | 5 | ☐ | [q12](q12_storageclass_dynamic_expand/) |
| 13 | NotReady 노드 복구 | Troubleshooting | 7 | ☐ | [q13](q13_node_notready_kubelet/) |
| 14 | CrashLoopBackOff 원인 분석 | Troubleshooting | 7 | ☐ | [q14](q14_pod_crashloopbackoff/) |
| 15 | Service에 Endpoints가 안 잡히는 문제 | Troubleshooting | 6 | ☐ | [q15](q15_service_no_endpoints/) |
| 16 | 정적 파드 매니페스트 오류로 죽은 컨트롤 플레인 | Troubleshooting | 5 | ☐ | [q16](q16_static_pod_manifest_error/) |
| 17 | CoreDNS 이름 해석 실패 | Troubleshooting | 5 | ☐ | [q17](q17_coredns_resolution_failure/) |

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
