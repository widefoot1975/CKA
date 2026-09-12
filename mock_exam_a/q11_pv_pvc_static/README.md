# q11 — PV/PVC 정적 프로비저닝과 마운트

| 항목 | 내용 |
|---|---|
| 회차 | mock_exam_a |
| 도메인 | Storage (10%) |
| 배점 | 5 |
| 컨텍스트 | `kubectl config use-context k8s-c1` |
| 목표 시간 | 8분 |
| 결과 | ☐ 정답 ☐ 부분 ☐ 오답 |

## 문제

1. PersistentVolume `data-pv` 를 만든다.
   - 용량 2Gi, 접근 모드 `ReadWriteOnce`, `hostPath` 는 `/mnt/data`
   - `persistentVolumeReclaimPolicy` 는 `Retain`
   - `storageClassName` 은 `manual`
2. PersistentVolumeClaim `data-pvc` 를 만든다. 용량 1Gi 요청, 같은 접근 모드와 storageClass.
3. 파드 `data-pod` (이미지 `nginx`)에서 이 PVC를 `/usr/share/nginx/html` 에 마운트한다.
4. PVC가 `Bound` 되고 파드가 `Running` 인지 확인한다.

## 내 풀이

```bash

```

<details>
<summary><b>모범 풀이</b> — 직접 풀고 나서 펼치세요</summary>

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data-pv
spec:
  capacity:
    storage: 2Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: manual
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: data-pod
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: data
      mountPath: /usr/share/nginx/html
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: data-pvc
```

```bash
kubectl apply -f q11.yaml
```

바인딩 조건은 **accessModes 일치 + storageClassName 일치 + PV 용량 ≥ PVC 요청**입니다. 셋 중 하나라도 어긋나면 PVC가 `Pending` 에 머무릅니다. 1Gi 요청에 2Gi PV가 붙는 것은 정상이고, 이때 PVC는 2Gi 전체를 차지합니다.

</details>

## 검증

```bash
kubectl get pv data-pv       # STATUS Bound, CLAIM default/data-pvc
kubectl get pvc data-pvc     # STATUS Bound, CAPACITY 2Gi
kubectl get pod data-pod     # Running

# Pending 이면 이유를 여기서 확인
kubectl describe pvc data-pvc | tail -15
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: PVC가 `Pending` 이면 거의 항상 accessModes / storageClassName / 용량 세 가지 중 하나의 불일치.
- **헷갈리는 지점**: `storageClassName: ""` (빈 문자열)과 필드를 아예 생략하는 것은 다릅니다. 생략하면 default StorageClass가 적용돼 엉뚱한 동적 프로비저닝이 일어납니다.

## 참고 문서

- 검색어: `persistent volume`
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
