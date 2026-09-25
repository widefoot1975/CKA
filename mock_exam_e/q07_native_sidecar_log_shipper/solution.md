# q07 — Add a native sidecar to an existing Deployment · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`synergy` 네임스페이스의 Deployment `synergy-app` 에는 몇 초마다 `/var/log/app.log` 에 한 줄씩
추가하는 컨테이너 `app`(`busybox:1.36`) 하나가 있다. 이 파일은 `/var/log` 에 마운트된 `emptyDir`
볼륨 `logs` 에 있다.

1. Deployment에 사이드카 컨테이너 `sidecar` 를 추가한다: 이미지 `busybox:1.36`, 명령
   `sh -c 'tail -n+1 -F /var/log/app.log'`, 볼륨 `logs` 를 `/var/log` 에 마운트.
2. 이 컨테이너를 **네이티브 사이드카**, 즉 파드가 살아 있는 동안 계속 실행되는 init 컨테이너로
   정의한다. 컨테이너 `app` 은 바꾸지 않는다.
3. 새 파드가 `2/2` Ready로 보이고, 컨테이너 `sidecar` 의 로그에 `app` 이 쓴 줄들이 나오는지 확인한다.

## 모범 풀이

```bash
kubectl -n synergy edit deploy synergy-app
```

`spec.template.spec` 아래, `containers` 와 같은 들여쓰기로 `initContainers` 를 추가합니다.

```yaml
    spec:
      initContainers:                  # ← 추가
      - name: sidecar
        image: busybox:1.36
        restartPolicy: Always          # 이 한 줄이 init 컨테이너를 네이티브 사이드카로 만든다
        command: ["sh", "-c", "tail -n+1 -F /var/log/app.log"]
        volumeMounts:
        - name: logs
          mountPath: /var/log
      containers:                      # 기존 그대로 (예시)
      - name: app
        image: busybox:1.36
        command: ["sh", "-c", "while true; do echo \"$(date) processed\" >> /var/log/app.log; sleep 5; done"]
        volumeMounts:
        - name: logs
          mountPath: /var/log
      volumes:
      - name: logs
        emptyDir: {}
```

저장하면 파드 템플릿이 바뀌었으므로 롤링 업데이트로 새 파드가 뜹니다.

**네이티브 사이드카 = `initContainers` + `restartPolicy: Always`** (1.29부터 기본 활성, 1.33 GA).

| | 일반 init 컨테이너 | 네이티브 사이드카 |
|---|---|---|
| 다음 컨테이너로 넘어가는 시점 | **종료(성공)** 한 뒤 | **시작**된 직후 |
| 앱 컨테이너가 도는 동안 | 이미 끝나 있음 | 계속 실행, 죽으면 재시작 |
| 파드 READY 칸 | 세지 않음 | 셈 (`2/2`) |

`restartPolicy: Always` 를 빼면 일반 init 컨테이너가 됩니다. `tail -F` 는 끝나지 않으므로 kubelet은
영원히 종료를 기다리고, 파드는 `Init:0/1` 에 멈춰 `app` 이 시작조차 못 합니다.

`-F` 를 쓰는 이유 — 사이드카는 `app` 보다 **먼저** 시작하므로 그 순간 `/var/log/app.log` 가 아직 없을
수 있습니다. `-F` 는 파일이 생길 때까지 기다렸다가 따라가고(파일이 새로 만들어져도 다시 엽니다),
`-f` 는 파일이 없으면 바로 실패합니다. `-n+1` 은 첫 줄부터 출력하라는 뜻입니다.

## 검증

```bash
kubectl -n synergy rollout status deploy synergy-app
kubectl -n synergy get pods
# NAME                           READY   STATUS    RESTARTS   AGE
# synergy-app-6d9f7c8b5d-x2k9p   2/2     Running   0          20s
kubectl -n synergy get deploy synergy-app \
  -o jsonpath='{.spec.template.spec.initContainers[0].restartPolicy}{"\n"}'     # Always
kubectl -n synergy logs deploy/synergy-app -c sidecar --tail=3
# Sat Sep 26 01:10:05 UTC 2026 processed
# ...
```

`logs deploy/...` 는 가장 오래 Ready 였던 파드를 고릅니다. `app` 의 `sh` 루프는 SIGTERM 을 무시해서 옛 파드가
최대 30초 동안 `Terminating` 으로 남는데, 그동안 옛 파드가 뽑히면 `container sidecar is not valid for pod ...`
가 납니다. 옛 파드가 사라진 뒤 다시 실행하거나, `get pods` 로 본 새 파드 이름을 직접 씁니다.

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 네이티브 사이드카는 `initContainers` 에 두고 **컨테이너 수준** `restartPolicy: Always` 를 준다. 빠뜨리면 파드가 `Init:0/1` 에서 멈춘다.
- **헷갈리는 지점**: 파드 수준 `spec.restartPolicy` 와 컨테이너 수준 `restartPolicy` 는 다른 필드입니다. 사이드카를 `containers` 에 나란히 두는 옛 방식도 로그는 보이지만, 시작 순서가 보장되지 않고 Job에서는 메인 컨테이너가 끝나도 파드가 끝나지 않습니다.

## 참고 문서

- 검색어: `sidecar containers`
- https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/
- https://kubernetes.io/docs/concepts/workloads/pods/init-containers/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
