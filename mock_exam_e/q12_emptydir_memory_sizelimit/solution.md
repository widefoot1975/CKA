# q12 — Share a scratch volume between containers · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`tmp` 네임스페이스는 이미 있다. 두 컨테이너가 임시 볼륨을 공유하는 Pod `cache-pod` 를 `tmp`
네임스페이스에 만든다.

1. 컨테이너 `producer`: 이미지 `busybox:1.36`, 명령 `sh -c 'echo hello > /cache/data; sleep 3600'`.
2. 컨테이너 `consumer`: 이미지 `busybox:1.36`, 명령 `sleep 3600`.
3. 두 컨테이너 모두 `emptyDir` 볼륨 `cache` 를 `/cache` 에 마운트한다. 볼륨은 메모리(tmpfs) 기반이어야
   하고 `64Mi` 로 제한한다.
4. `consumer` 가 `/cache/data` 를 읽을 수 있는지, 그 안에서 `/cache` 가 tmpfs 마운트인지 확인한다.

## 모범 풀이

뼈대는 `kubectl -n tmp run cache-pod --image=busybox:1.36 --dry-run=client -o yaml > cache-pod.yaml`
로 뽑고, 컨테이너 이름을 바꾼 뒤 두 번째 컨테이너와 볼륨을 붙입니다. 완성본:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cache-pod
  namespace: tmp
spec:
  volumes:
  - name: cache
    emptyDir:
      medium: Memory          # 디스크 대신 tmpfs(RAM)
      sizeLimit: 64Mi
  containers:
  - name: producer
    image: busybox:1.36
    command: ["sh", "-c", "echo hello > /cache/data; sleep 3600"]
    volumeMounts:
    - name: cache
      mountPath: /cache
  - name: consumer
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: cache
      mountPath: /cache
```

```bash
kubectl apply -f cache-pod.yaml
```

**emptyDir의 수명은 파드와 같습니다.** 파드가 노드에 배치될 때 빈 디렉터리로 만들어지고, 같은 파드의
컨테이너들이 함께 쓰며, 컨테이너가 죽었다 재시작해도 남아 있다가 **파드가 삭제되면 영구히
사라집니다.** 그래서 캐시나 작업 공간 용도이고, 남겨야 하는 데이터는 PVC에 둡니다.

`medium: Memory` 는 빠르지만 **여기에 쓴 파일은 그 파일을 쓴 컨테이너의 메모리 사용량으로 계산되어
memory limit에 포함됩니다.** 큰 파일을 쓰면 OOMKilled의 원인이 될 수 있습니다. `sizeLimit: 64Mi` 를
주면 tmpfs 크기가 64Mi로 잡혀, 그 이상 쓰면 `No space left on device` 로 실패합니다.

## 검증

```bash
kubectl -n tmp get pod cache-pod                                  # READY 2/2, Running
kubectl -n tmp exec cache-pod -c consumer -- cat /cache/data      # hello
kubectl -n tmp exec cache-pod -c consumer -- df -h /cache
# Filesystem                Size      Used Available Use% Mounted on
# tmpfs                    64.0M      4.0K     64.0M   0% /cache
kubectl -n tmp exec cache-pod -c consumer -- grep /cache /proc/mounts
# tmpfs /cache tmpfs rw,...
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `emptyDir: {medium: Memory, sizeLimit: 64Mi}` — 파드와 수명이 같고, 메모리 기반이면 쓴 만큼 컨테이너 메모리로 계산된다.
- **헷갈리는 지점**: `kubectl exec cache-pod -- ...` 처럼 `-c` 를 빼면 에러 없이 첫 번째 컨테이너(`producer`)에서 실행되고 stderr에 `Defaulted container` 한 줄만 남습니다. "consumer가 읽을 수 있는지"는 `-c consumer` 로 증명합니다. `sizeLimit` 은 볼륨 필드로, 컨테이너의 `resources.limits` 와는 별개입니다.

## 참고 문서

- 검색어: `volumes emptydir`
- https://kubernetes.io/docs/concepts/storage/volumes/#emptydir
- https://kubernetes.io/docs/tasks/access-application-cluster/communicate-containers-same-pod-shared-volume/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
