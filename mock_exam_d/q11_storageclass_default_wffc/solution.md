# q11 — Create a default StorageClass · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

local-path 프로비저너(`rancher.io/local-path`)가 설치되어 있고, 클러스터에는 이미 기본(default)
StorageClass가 있다.

1. provisioner `rancher.io/local-path`, reclaimPolicy `Delete`, volumeBindingMode `WaitForFirstConsumer`
   인 StorageClass `local-fast` 를 만든다.
2. `local-fast` 를 클러스터의 기본 StorageClass로 만든다.
3. 이전에 기본이던 StorageClass(`kubectl get sc` 로 확인)가 더 이상 기본이 아니게 하고, `(default)` 표시가
   붙은 StorageClass가 정확히 하나인지 확인한다.

## 모범 풀이

```bash
kubectl get sc
# NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
# local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  30d
```

StorageClass는 명령형 생성 명령이 없으므로 yaml로 만듭니다.

```yaml
# local-fast.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-fast
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"    # 문자열이라 따옴표 필수
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

```bash
kubectl apply -f local-fast.yaml
kubectl patch sc local-path -p \
  '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

**기본 StorageClass는 어노테이션 하나로 정해집니다.** `storageClassName` 을 **아예 적지 않은** PVC가 만들어질
때 기본 클래스가 채워집니다. `storageClassName: ""` 처럼 빈 문자열을 명시하면 "클래스 없음"(정적 PV에만
바인딩)이라 기본값이 적용되지 않습니다. 기본이 둘 이상이면 v1.26부터는 가장 최근에 만든 기본 클래스가
쓰이지만, 헷갈리지 않도록 하나만 남기는 것이 원칙입니다.

**`WaitForFirstConsumer`** 는 PVC를 만들어도 바로 볼륨을 만들지 않고, 그 PVC를 쓰는 파드가 스케줄될 때까지
기다렸다가 **파드가 배치된 노드에** 볼륨을 만듭니다. local-path처럼 노드 디스크를 쓰는 스토리지에 필요한
설정이고, 그동안 PVC가 `Pending` 인 것은 정상입니다. `Immediate`(기본값)는 PVC를 만들자마자 프로비저닝합니다.

## 검증

```bash
kubectl get sc
# NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
# local-fast (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  20s
# local-path             rancher.io/local-path   Delete          WaitForFirstConsumer   false                  30d
kubectl get sc | grep -c '(default)'        # 1
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 기본 클래스 = 어노테이션 `storageclass.kubernetes.io/is-default-class: "true"`. 새 기본을 지정하면 옛 기본은 `"false"` 로 내린다.
- **헷갈리는 지점**: StorageClass의 `provisioner`, `parameters`, `reclaimPolicy`, `volumeBindingMode` 는 만든 뒤 바꿀 수 없어 지우고 다시 만들어야 합니다(어노테이션은 바꿀 수 있음). 기본 클래스를 바꿔도 이미 클래스가 채워진 PVC는 그대로입니다.

## 참고 문서

- 검색어: `change the default storageclass`, `storage classes`
- https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/
- https://kubernetes.io/docs/concepts/storage/storage-classes/#volume-binding-mode

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
