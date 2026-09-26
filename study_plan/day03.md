# 3일차 (D-8) — kubeadm · 인증서 · 노드 준비 · HA

[← 2일차](day02.md) · [계획 전체](README.md) · [4일차 →](day04.md)

## 오늘의 목표

Cluster Architecture(25%) 중 **노드에 `ssh` 해서 하는 작업**을 익힙니다. 명령 순서를 외워야 하는 항목이라, 오늘은 순서를 틀리지 않는 데 집중합니다.

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:15 | [exam_guide.md](../exam_guide.md) §4.2 노드 준비, §4.3 kubeadm, §4.4 HA 컨트롤 플레인, §4.7 확장 인터페이스 |
| 0:15 – 0:40 | 아래 문제 4개 풀기 |
| 0:40 – 0:55 | `solution.md` 와 대조, 오답 원인 기록 |
| 0:55 – 1:00 | [cheatsheet.md](../cheatsheet.md) §5 kubeadm 업그레이드 순서를 종이에 한 번 적어 보기 |

## 풀 문제

| 문제 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|
| D04 | 컨트롤 플레인 인증서 확인·갱신 | 6 | 6분 | [Q](../mock_exam_d/q04_kubeadm_cert_renewal/question.md) · [S](../mock_exam_d/q04_kubeadm_cert_renewal/solution.md) ☐ |
| F03 | kubeadm으로 워커 노드 하나 업그레이드 | 6 | 6분 | [Q](../mock_exam_f/q03_kubeadm_upgrade_worker/question.md) · [S](../mock_exam_f/q03_kubeadm_upgrade_worker/solution.md) ☐ |
| E01 | cri-dockerd 설치와 커널 파라미터 설정 | 7 | 7분 | [Q](../mock_exam_e/q01_cri_dockerd_node_prep/question.md) · [S](../mock_exam_e/q01_cri_dockerd_node_prep/solution.md) ☐ |
| E04 | HA 컨트롤 플레인 점검 | 6 | 6분 | [Q](../mock_exam_e/q04_ha_control_plane_inspect/question.md) · [S](../mock_exam_e/q04_ha_control_plane_inspect/solution.md) ☐ |

합계 25점, 목표 25분. 업그레이드는 패키지 설치를 기다리느라 실제 시간이 목표를 넘을 수 있습니다. 시험장에서는 이런 문제를 뒤로 미룹니다.

## 꼭 잡을 것

```bash
kubeadm certs check-expiration
kubeadm certs renew apiserver            # 그 다음 정적 파드 재시작 (매니페스트를 잠깐 밖으로 옮겼다 되돌리기)

# 워커 업그레이드: 저장소 버전 변경 → kubeadm → upgrade node → drain → kubelet·kubectl → restart → uncordon
kubeadm upgrade node
kubectl drain <node> --ignore-daemonsets
systemctl daemon-reload && systemctl restart kubelet
kubectl uncordon <node>

sysctl --system                          # /etc/sysctl.d/ 에 넣은 값 적용
crictl ps -a
```

- kubeadm 업그레이드는 **노드마다** 패키지 저장소 버전을 바꿔야 합니다. 워커와 두 번째 컨트롤 플레인은 `apply` 가 아니라 `upgrade node` 입니다 (함정 9).
- 유닛·드롭인 파일을 고친 뒤 `daemon-reload` 없이 restart하면 반영되지 않습니다 (함정 10).
- `kubeadm certs renew` 뒤에는 정적 파드를 재시작해야 새 인증서를 읽습니다 (함정 11).
- 정적 파드 매니페스트 백업을 `/etc/kubernetes/manifests` 안에 두면 `.bak` 도 읽힙니다 (함정 12).

## 여유가 있으면

- 기본 [F04 사용 중인 CRI·CNI·CSI 확인](../mock_exam_f/q04_extension_interfaces_inventory/question.md)
- 심화 [A02 kubeadm 클러스터 업그레이드](../mock_exam_a/q02_kubeadm_cluster_upgrade/question.md)
- 심화 [B01 HA 컨트롤 플레인 검증·운영](../mock_exam_b/q01_ha_control_plane/question.md)
