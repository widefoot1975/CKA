# q13 — Bring a NotReady node back · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

노드 `worker01` 이 `NotReady` 로 보고된다. 원인은 노드 자체에 있다.

1. `k8s-c1` 에서 `worker01` 의 어느 condition이 실패했고 어떤 메시지가 보고되는지 찾는다.
2. `worker01` 에서 원인을 찾아, 재부팅 후에도 노드가 `Ready` 로 돌아오도록 고친다.
3. 원인을 한 줄로 `worker01` 의 `/opt/course/d13/cause.txt` 에 적는다.
4. `worker01` 이 `Ready` 인지 확인한다.

## 모범 풀이

**1) k8s-c1 — 무엇이 실패했는가**

```bash
kubectl get nodes                        # worker01   NotReady   <none>   30d   v1.35.x
kubectl describe node worker01 | grep -A7 Conditions
# Type             Status    Reason              Message        (시간 열 생략)
# MemoryPressure   Unknown   NodeStatusUnknown   Kubelet stopped posting node status.
# ...
# Ready            Unknown   NodeStatusUnknown   Kubelet stopped posting node status.
```

`Ready=Unknown` + `Kubelet stopped posting node status` 는 kubelet이 **보고 자체를 못 하고 있다**는
뜻입니다(프로세스가 없거나 API 서버에 닿지 못함). kubelet이 살아서 문제를 보고하는 경우라면
`Ready=False` 와 구체적인 메시지가 나옵니다. 그래서 다음에 볼 곳은 노드의 kubelet 서비스입니다.

**2) worker01 — kubelet 서비스 상태**

```bash
ssh worker01
sudo -i
systemctl status kubelet
# ○ kubelet.service - kubelet: The Kubernetes Node Agent
#      Loaded: loaded (.../kubelet.service; disabled; preset: enabled)
#      Active: inactive (dead) since ...
journalctl -u kubelet -n 20 --no-pager   # 마지막이 "Stopped kubelet.service ..." — 크래시가 아니라 정지됨
```

`inactive (dead)` 는 멈춰 있다는 뜻이고, `Loaded:` 줄의 `disabled` 는 **부팅할 때 자동으로 시작되지 않는다**는
뜻입니다. 원인은 이 두 가지가 합쳐진 하나의 상태 — kubelet 서비스가 정지되고 비활성화된 것입니다.

```bash
systemctl enable --now kubelet           # enable(부팅 시 시작) + start(지금 시작)
systemctl is-enabled kubelet             # enabled
systemctl is-active kubelet              # active

mkdir -p /opt/course/d13
echo "kubelet service on worker01 was stopped and disabled" > /opt/course/d13/cause.txt
```

**핵심은 `start` 와 `enable` 의 차이입니다.** `systemctl start`(또는 `restart`)만 하면 지금은 `Ready` 로
돌아오지만 재부팅하면 다시 `NotReady` 가 됩니다. "재부팅 후에도"라는 조건은 `enable` 을 요구합니다.

## 검증

```bash
exit; exit                                # k8s-c1 로 돌아온다
kubectl get node worker01                 # Ready (수십 초 걸릴 수 있음)
kubectl describe node worker01 | grep -E 'Taints|KubeletReady'
# Taints:  <none>                         ← unreachable taint 가 자동으로 사라진다
# Ready    True   ...   KubeletReady   kubelet is posting ready status
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `Ready=Unknown` → kubelet부터 본다. 고칠 때는 `systemctl enable --now kubelet` 으로 지금 시작하고 부팅 시 시작도 켠다.
- **헷갈리는 지점**: `systemctl status` 의 `Active:` 줄은 지금 상태, `Loaded:` 줄의 `enabled/disabled` 는 부팅 시 동작입니다. 둘 다 봐야 합니다. 유닛이 `masked` 로 나오면 `enable` 도 실패하므로 `systemctl unmask kubelet` 이 먼저입니다.

## 참고 문서

- 검색어: `troubleshooting clusters`, `node status`
- https://kubernetes.io/docs/tasks/debug/debug-cluster/
- https://kubernetes.io/docs/reference/node/node-status/#condition

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
