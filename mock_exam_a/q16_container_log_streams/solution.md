# q16 — Read and evaluate container output streams · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`logs` 네임스페이스의 Deployment `multi` 는 3 레플리카를 돌리고, 각 파드는 애플리케이션 컨테이너 `app` 과 로그 수집기 `shipper` 를 갖고 있다.

1. `app` 의 출력만 출력하고, 이어서 한 파드의 두 컨테이너 출력을 한 번에, 각 줄에 컨테이너 이름을 붙여서 출력한다.
2. `app` 의 마지막 20줄을 타임스탬프와 함께 출력하고, 이어서 최근 5분 동안 생긴 줄만 출력한다.
3. `app` 을 실시간으로 따라가고, 재시작 후에는 이전 인스턴스의 출력을 출력한다.
4. Deployment 전체에 대해 출력하고, 이어서 파드 3개 전부에 대해 출력한 뒤, 이 둘이 같지 않은 이유를 한 줄로 적는다.
5. 노드에서 이 컨테이너 중 하나의 디스크상 로그 파일을 찾고, `kubectl` 대신 `crictl` 로 같은 출력을 읽는다.
6. `shipper` 가 `app` 보다 먼저 시작해 파드가 사는 동안 계속 돌게 하려면 어떻게 선언해야 하는지 한 줄로 적는다.

## 모범 풀이

```bash
POD=$(kubectl -n logs get pod -l app=multi -o jsonpath='{.items[0].metadata.name}')

kubectl -n logs logs $POD -c app
kubectl -n logs logs $POD --all-containers=true --prefix       # 줄마다 [pod/컨테이너] 접두

kubectl -n logs logs $POD -c app --tail=20 --timestamps
kubectl -n logs logs $POD -c app --since=5m
kubectl -n logs logs $POD -c app --since-time=2026-09-12T09:00:00Z

kubectl -n logs logs -f $POD -c app
kubectl -n logs logs $POD -c app --previous                    # 죽은 직전 인스턴스
```

**컨테이너가 둘 이상이면 `-c` 는 선택이 아닙니다.** 생략하면 `error: a container name must be specified for pod ...` 가 나거나 기본 컨테이너 어노테이션이 있는 쪽으로 조용히 넘어갑니다.

**4) Deployment 로그와 모든 파드의 로그는 다릅니다**

```bash
kubectl -n logs logs deploy/multi -c app          # 파드 하나만 골라서 보여준다
kubectl -n logs logs -l app=multi -c app --prefix --max-log-requests=10
```

`kubectl logs deploy/X` 는 워크로드를 대신 지목하는 편의 문법일 뿐이고, 내부적으로 그 Deployment의 파드 **하나**를 골라 그 로그를 보여줍니다. 3개 파드 전부를 보려면 **라벨 셀렉터** `-l` 를 써야 합니다. `-l` 로 5개를 넘는 파드를 따라가려면 `--max-log-requests` 를 올려야 합니다(기본 5, 넘으면 에러).

**stdout과 stderr은 분리되지 않습니다.** kubelet은 컨테이너의 두 스트림을 한 로그 파일에 시간순으로 합쳐 기록하고, `kubectl logs` 에는 이를 나누는 옵션이 없습니다. 각 줄에 `stdout`/`stderr` 태그가 파일에는 들어 있지만 kubectl 출력에는 나오지 않습니다. 구분이 필요하면 애플리케이션이 다른 목적지로 써야 합니다.

**5) 노드에서 직접 읽기**

```bash
ls -l /var/log/containers/            # <pod>_<ns>_<container>-<id>.log 형태의 심볼릭 링크
ls -l /var/log/pods/logs_${POD}_<uid>/app/
# 0.log, 1.log ... 재시작마다 번호가 올라간다. --previous 가 읽는 것이 앞 번호 파일이다
tail -20 /var/log/pods/logs_${POD}_*/app/0.log
```

`/var/log/containers/*.log` 는 `/var/log/pods/.../N.log` 를 가리키는 심볼릭 링크이고, 그 파일이 실제 컨테이너 런타임 로그입니다. 각 줄은 `<RFC3339 타임스탬프> <stdout|stderr> <F|P> <내용>` 형식입니다.

```bash
crictl ps -a | grep app
CID=$(crictl ps -a -q --name app | head -1)
crictl logs $CID
crictl logs --tail 20 --timestamps $CID
crictl logs -p $CID                   # kubectl logs --previous 에 해당
crictl pods --namespace logs
```

`crictl` 은 apiserver를 거치지 않고 노드의 런타임 소켓에 직접 말합니다. **컨트롤 플레인이 죽어 `kubectl` 이 안 될 때 유일한 수단**입니다. 소켓 경로 경고가 나면 `--runtime-endpoint unix:///run/containerd/containerd.sock` 를 붙이거나 `/etc/crictl.yaml` 에 적어 둡니다.

**6) 사이드카 선언** — 네이티브 사이드카는 **`restartPolicy: Always` 를 가진 init container** 입니다.

```yaml
spec:
  initContainers:
  - name: shipper
    image: busybox:1.36
    restartPolicy: Always            # 이 한 줄이 사이드카로 만든다
    command: ["sh", "-c", "tail -F /var/log/app/out.log"]
  containers:
  - { name: app, image: busybox:1.36 }
```

init container이므로 `app` 보다 **먼저** 시작하고, `restartPolicy: Always` 때문에 끝나기를 기다리지 않고 다음 컨테이너로 넘어가며 파드가 사는 동안 계속 돕니다. 종료 시에는 일반 컨테이너들이 먼저 끝난 뒤에 정리됩니다. 평범한 init container(`restartPolicy` 없음)로 두면 파드가 영원히 기동 중에 멈춥니다. 참고로 사이드카도 `-c shipper` 로 로그를 읽습니다 — `initContainers` 에 있어도 조회 방법은 같습니다.

## 검증

```bash
kubectl -n logs logs $POD --all-containers --prefix --tail=5
# [pod/multi-xxxx/app] ...   그리고 [pod/multi-xxxx/shipper] ...
kubectl -n logs logs -l app=multi -c app --prefix --tail=2 | grep -c '^\[pod/'  # 6 (3파드x2줄)
kubectl -n logs logs deploy/multi -c app --tail=2 | wc -l                       # 2 (파드 1개)
kubectl -n logs logs $POD -c app --timestamps --tail=3     # 각 줄 앞에 RFC3339 시각
crictl ps -a --name app                                    # 노드에서
crictl logs --tail 5 $(crictl ps -q --name app | head -1)
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `kubectl logs deploy/X` 는 파드 **하나**만 본다. 전부 보려면 `-l <셀렉터>`.
- **헷갈리는 지점**: `--previous`(직전에 죽은 인스턴스)와 `--since`(시간 범위)는 목적이 다릅니다. 재시작한 파드의 사고 원인은 `--since` 로는 안 나옵니다. 그리고 `-c` 는 로그를 읽을 컨테이너 선택이고 `--all-containers` 는 전부인데, 후자에 `-c` 를 같이 주면 무시됩니다. `/var/log/containers` 는 링크, 실체는 `/var/log/pods` 입니다.

## 참고 문서

- 검색어: `logging architecture`
- https://kubernetes.io/docs/concepts/cluster-administration/logging/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
