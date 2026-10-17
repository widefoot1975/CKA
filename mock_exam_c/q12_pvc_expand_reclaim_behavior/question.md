# q12 — Expand a PVC and observe reclaim behaviour

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 1) local-path 프로비저너 v0.0.37 설치 (provisioner rancher.io/local-path)
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.37/deploy/local-path-storage.yaml
kubectl -n local-path-storage rollout status deploy local-path-provisioner --timeout=180s

# 2) 이전 실습 흔적 정리
#    slow-retain PV 는 Retain 이라 PVC 를 지워도 남는다 → Delete 로 되돌린 뒤 namespace 를 지우고 남은 PV 를 지운다
#    (5번에서 claimRef 를 지운 PV 는 namespace 정보가 없으므로 클래스 이름으로 찾는다)
for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.storageClassName=="slow-retain")]}{.metadata.name}{"\n"}{end}'); do
  kubectl patch pv "$pv" -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}'
done
kubectl delete ns files --ignore-not-found --wait=true
for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.storageClassName=="slow-retain")]}{.metadata.name}{"\n"}{end}{range .items[?(@.spec.claimRef.namespace=="files")]}{.metadata.name}{"\n"}{end}'); do
  # Released 는 프로비저너가 디렉터리째 지우도록 잠시 기다리고, Available(5번에서 claimRef 를 지운 것)은 바로 지운다
  if [ "$(kubectl get pv "$pv" -o jsonpath='{.status.phase}' 2>/dev/null)" = "Released" ]; then
    kubectl wait --for=delete "pv/$pv" --timeout=60s || true
  fi
  kubectl delete pv "$pv" --ignore-not-found --wait=true
done
kubectl delete sc slow slow-retain --ignore-not-found

# 3) StorageClass slow — 확장을 허용하지 않는 상태로 시작 (allowVolumeExpansion 없음)
#    apply 대신 create 로 만들어 last-applied 어노테이션이 붙지 않게 한다 (4번에서 yaml 을 복사하기 쉽게)
kubectl create -f - <<'YAML'
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: slow
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
YAML

# 4) namespace files, PVC archive (1Gi, slow) 와 그것을 /data 에 마운트한 파드 writer
#    WaitForFirstConsumer 라서 파드가 떠야 PV 가 만들어지고 Bound 된다
kubectl create ns files
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: archive, namespace: files}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: slow
  resources: {requests: {storage: 1Gi}}
---
apiVersion: v1
kind: Pod
metadata: {name: writer, namespace: files}
spec:
  containers:
  - name: writer
    image: busybox:1.36
    command: [sh, -c, "date > /data/started.txt; sleep 86400"]
    volumeMounts: [{name: data, mountPath: /data}]
  volumes:
  - name: data
    persistentVolumeClaim: {claimName: archive}
YAML
kubectl -n files wait pod writer --for=condition=Ready --timeout=180s
kubectl -n files wait pvc archive --for=jsonpath='{.status.phase}'=Bound --timeout=60s

# 5) 시작 상태 확인: slow 의 ALLOWVOLUMEEXPANSION 은 false, archive 는 1Gi Bound, writer 는 Running
kubectl get sc slow
kubectl -n files get pvc,pod
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

local-path 프로비저너 v0.0.37(B11·F11 과 같은 설치)을 쓴다. 설정 직후 StorageClass `slow`(`rancher.io/local-path`, `Delete`, `WaitForFirstConsumer`)는 `ALLOWVOLUMEEXPANSION` 이 `false`(필드 없음)이고, `files` 에는 1Gi `Bound` PVC `archive` 와 그것을 `/data` 에 마운트한 `writer` 가 `Running` 이다.
**이 환경에서는 2번의 확장이 끝나지 않는다.** local-path 는 볼륨 확장을 지원하지 않아서, `allowVolumeExpansion` 을 켠 뒤 PVC 를 `3Gi` 로 패치하면 API 서버는 받아 주지만 실제로 늘려 줄 컨트롤러가 없다. `spec` 은 `3Gi`, `status.capacity` 는 `1Gi` 에 머물고 `df` 는 볼륨이 아니라 노드 디스크 크기를 보여 준다. 1번, 2번의 패치, 3번(축소 거부), 4·5번(Retain·Released·Available)은 그대로 연습할 수 있고, 끝까지 늘어나는 것을 보려면 확장을 지원하는 CSI 드라이버(Longhorn, TopoLVM 등)가 필요하다.
`Retain` PV 는 PVC 를 지워도 남으므로 `setup.sh`·`cleanup.sh` 는 `slow-retain` PV 를 `Delete` 로 되돌린 뒤 정리한다. 5번에서 `Available` 로 돌린 PV 는 프로비저너가 지우지 않으므로 노드의 `/opt/local-path-provisioner/pvc-…_files_scratch` 디렉터리가 남을 수 있다. A12 는 `slow` 라는 StorageClass 가 없다는 전제로 풀리므로, A12 를 풀기 전에 이 문제의 `cleanup.sh` 를 꼭 실행한다. 프로비저너는 남겨 둔다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.storageClassName=="slow-retain")]}{.metadata.name}{"\n"}{end}'); do
  kubectl patch pv "$pv" -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}'
done
kubectl delete ns files --ignore-not-found --wait=true
for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.storageClassName=="slow-retain")]}{.metadata.name}{"\n"}{end}{range .items[?(@.spec.claimRef.namespace=="files")]}{.metadata.name}{"\n"}{end}'); do
  # Released 는 프로비저너가 디렉터리째 지우도록 잠시 기다리고, Available(5번에서 claimRef 를 지운 것)은 바로 지운다
  if [ "$(kubectl get pv "$pv" -o jsonpath='{.status.phase}' 2>/dev/null)" = "Released" ]; then
    kubectl wait --for=delete "pv/$pv" --timeout=60s || true
  fi
  kubectl delete pv "$pv" --ignore-not-found --wait=true
done
kubectl delete sc slow slow-retain --ignore-not-found
```

</details>

## Task

Namespace `files` has a PVC `archive` of 1Gi, `Bound`, using StorageClass `slow`, and a
pod `writer` mounting it at `/data`. The CSI driver behind `slow` supports online
expansion.

1. Check whether `slow` allows volume expansion. `archive` must be expanded where it is,
   so if expansion is not allowed, change what is needed — a bound PVC cannot move to
   another class.
2. Expand `archive` from 1Gi to 3Gi and confirm the filesystem inside `writer` sees the
   new size, without restarting `writer`.
3. Attempt to shrink `archive` back to 1Gi and record the exact error.
4. Create StorageClass `slow-retain`, identical to `slow` except reclaim policy `Retain`.
   Create a PVC `scratch` (500Mi) from it and make sure it actually gets a PV, then delete
   the claim and report the state of that PV and why it is in that state.
5. Make that PV available for a new claim again without deleting it.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
