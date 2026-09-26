# 7일차 (D-4) — 트러블슈팅 ① 노드 · 컨트롤 플레인

[← 6일차](day06.md) · [계획 전체](README.md) · [8일차 →](day08.md)

## 오늘의 목표

배점이 가장 큰 Troubleshooting(30%)의 전반부입니다. **노드 NotReady** 와 **컨트롤 플레인 컴포넌트 장애**를 진단하는 순서를 몸에 익힙니다. 트러블슈팅 문제는 배점 × 1.33분이라 문제당 시간이 조금 더 깁니다.

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:12 | [exam_guide.md](../exam_guide.md) §8.1 접근법, §8.2 노드 NotReady, §8.3 컨트롤 플레인 컴포넌트 |
| 0:12 – 0:46 | 아래 문제 4개 풀기 |
| 0:46 – 0:58 | `solution.md` 와 대조, 오답 원인 기록 |
| 0:58 – 1:00 | 회차 README의 `실제`·`결과` 칸 채우기 |

## 풀 문제

| 문제 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|
| D13 | NotReady 노드 복구 | 7 | 9분 | [Q](../mock_exam_d/q13_node_kubelet_stopped/question.md) · [S](../mock_exam_d/q13_node_kubelet_stopped/solution.md) ☐ |
| E14 | 컨테이너 런타임이 죽어 노드 NotReady | 6 | 8분 | [Q](../mock_exam_e/q14_node_containerd_stopped/question.md) · [S](../mock_exam_e/q14_node_containerd_stopped/solution.md) ☐ |
| D14 | 스케줄러 고장으로 파드가 Pending | 6 | 8분 | [Q](../mock_exam_d/q14_scheduler_static_pod_image/question.md) · [S](../mock_exam_d/q14_scheduler_static_pod_image/solution.md) ☐ |
| E13 | 머신 이전 후 API 서버 다운 | 7 | 9분 | [Q](../mock_exam_e/q13_apiserver_wrong_etcd_endpoint/question.md) · [S](../mock_exam_e/q13_apiserver_wrong_etcd_endpoint/solution.md) ☐ |

합계 26점, 목표 34분.

## 꼭 잡을 것

```bash
# 노드 (해당 노드에 ssh 후)
systemctl status kubelet containerd
journalctl -u kubelet --no-pager | tail -30
systemctl enable --now kubelet

# 컨트롤 플레인 — kubectl 이 안 되면 crictl 과 파일로
ls /etc/kubernetes/manifests/
crictl ps -a | grep -E 'apiserver|scheduler|etcd|controller'
crictl logs <container-id>
ls /var/log/pods/
```

- 노드 상태를 먼저 읽습니다. `Ready=Unknown` 이면 kubelet이 보고를 못 하는 것(죽었거나 API에 닿지 못함), `Ready=False` 와 메시지가 있으면 kubelet은 살아 있고 문제(CNI 등)를 보고 중입니다.
- API 서버가 죽으면 `kubectl` 이 안 됩니다. 이때는 `crictl` 과 `/var/log/pods` 로 봅니다.
- 유닛 파일을 고쳤으면 `daemon-reload` 부터 합니다 (함정 10).
- `crictl ps -a` 는 있지만 `crictl pods -a` 는 없는 플래그입니다 (함정 13).
- 매니페스트 백업은 `/etc/kubernetes/manifests` **밖에** 둡니다 (함정 12).

## 여유가 있으면

- 기본 [F13 kubelet 설정 변경 후 NotReady](../mock_exam_f/q13_kubelet_wrong_runtime_endpoint/question.md) — 9일차 모의고사에 들어가니 오늘은 건너뛰어도 됩니다
- 심화 [A17 정적 파드 매니페스트 오류로 컨트롤 플레인 다운](../mock_exam_a/q17_static_pod_manifest_error/question.md)
- 심화 [B16 컨트롤 플레인 컴포넌트 미실행](../mock_exam_b/q16_control_plane_component_down/question.md)
