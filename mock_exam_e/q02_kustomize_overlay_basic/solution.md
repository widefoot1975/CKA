# q02 — Apply a Kustomize overlay · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`/opt/course/e02/base/` 에 애플리케이션 `api` 의 Kustomize 베이스가 있다. Deployment `api`(이미지
`nginx:1.27`, 레플리카 1), Service `api`, `kustomization.yaml` 로 되어 있다. `base/` 아래의 파일은
하나도 수정하지 않는다.

1. 베이스를 사용하는 `/opt/course/e02/overlays/staging/kustomization.yaml` 을 만든다. 이 오버레이는
   - 모든 리소스를 네임스페이스 `staging` 에 두고,
   - Deployment `api` 의 레플리카를 `2` 로 하고,
   - 이미지 `nginx` 를 `nginx:1.28` 로 바꾸고,
   - 모든 리소스에 레이블 `env: staging` 을 붙이되 셀렉터는 하나도 **바꾸지 않는다**.
2. 네임스페이스 `staging` 을 만들고 `kubectl kustomize` 로 오버레이를 렌더링해 확인한다.
3. `kubectl apply -k` 로 오버레이를 적용하고, `staging` 의 Deployment `api` 가 `nginx:1.28` 로
   레플리카 2개 모두 Ready인지 확인한다.

## 모범 풀이

**베이스에서 이름 두 개를 먼저 확인합니다** — 리소스 이름(`api`)과 이미지 이름(`nginx`).

```bash
cat /opt/course/e02/base/kustomization.yaml                     # resources: deployment.yaml, service.yaml
grep -n 'name:\|image:' /opt/course/e02/base/deployment.yaml    # name: api ... image: nginx:1.27
```

**1) 오버레이** — `mkdir -p /opt/course/e02/overlays/staging` 후 `kustomization.yaml` 을 씁니다.

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base                # 오버레이 디렉터리 기준 상대 경로
namespace: staging
replicas:
  - name: api                 # 리소스(Deployment) 이름
    count: 2
images:
  - name: nginx               # 리소스 이름이 아니라 컨테이너의 이미지 이름
    newTag: "1.28"            # 태그는 따옴표로 감싸 문자열로 둔다
labels:
  - pairs:
      env: staging
    includeSelectors: false   # metadata.labels 에만 붙이고 셀렉터는 건드리지 않는다
```

**이 문제의 핵심은 각 `name` 이 무엇을 가리키는지입니다.** `replicas[].name` 은 **리소스 이름**이고,
`images[].name` 은 컨테이너 `image:` 값에서 태그를 뺀 **이미지 이름**입니다. `images` 에 `name: api`
라고 쓰면 맞는 이미지가 없어 **에러 없이 무시**되고 `nginx:1.27` 그대로 렌더링됩니다.

셀렉터를 건드리지 않는 이유 — Deployment의 `spec.selector` 는 생성 후 바꿀 수 없어서, 셀렉터에도
레이블을 넣는 구식 `commonLabels` 는 배포된 뒤 레이블을 바꾸면 apply가 거부됩니다. `labels` +
`includeSelectors: false` 는 메타데이터에만 붙입니다. `namespace:` 는 Namespace를 만들지 않습니다.

**2~3) 렌더링 → 적용**

```bash
kubectl create namespace staging
kubectl kustomize /opt/course/e02/overlays/staging        # 출력만 — 클러스터는 건드리지 않는다
kubectl apply -k /opt/course/e02/overlays/staging
# service/api created
# deployment.apps/api created
```

## 검증

```bash
kubectl -n staging rollout status deploy api
kubectl -n staging get deploy,svc -l env=staging
# deployment.apps/api   2/2   2   2   ...
# service/api           ClusterIP   ...
kubectl -n staging get deploy api -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'   # nginx:1.28
kubectl -n staging get deploy api -o jsonpath='{.spec.selector.matchLabels}{"\n"}'   # env 키가 없어야 한다
kubectl -n staging get endpointslice -l kubernetes.io/service-name=api               # 파드 IP 2개
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `replicas[].name` 은 리소스 이름, `images[].name` 은 이미지 이름이다. 렌더링은 `kubectl kustomize DIR`, 적용은 `kubectl apply -k DIR`.
- **헷갈리는 지점**: `kubectl apply -f overlays/staging/` 는 `kustomization.yaml` 을 일반 매니페스트로 읽으려다 실패합니다 — kustomize 디렉터리는 `-k` 로 적용합니다. `bases:`, `commonLabels:`, `patchesStrategicMerge:` 는 구식 필드이고 지금은 `resources:`, `labels:`, `patches:` 를 씁니다.

## 참고 문서

- 검색어: `kustomize declarative management`
- https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
