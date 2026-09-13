# q02 — Deploy an environment overlay with Kustomize · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`/opt/course/q02/base/` 에 베이스 매니페스트가 있다. `deployment.yaml` (Deployment `web`,
이미지 `nginx:1.25`, 레플리카 1), `service.yaml`, `kustomization.yaml` 로 구성된다.

`base/` 아래 파일을 하나도 수정하지 않고 `/opt/course/q02/overlays/prod/` 에 프로덕션
오버레이를 만든다.

1. 베이스를 참조한다.
2. 네임스페이스 `prod-web` 에 배포한다 (네임스페이스를 만든다).
3. 모든 리소스 이름에 `prod-` 접두사를 붙인다.
4. 모든 리소스에 `env: prod` 레이블을 추가한다.
5. `web` Deployment의 레플리카를 4로 한다.
6. 이미지를 `nginx:1.27` 로 바꾼다.
7. 리터럴 `TIER=prod` 와 `LOG_LEVEL=warn` 로 생성되는 ConfigMap `web-config` 를 추가한다.
8. 명시적 `target` 을 가진 patch로 컨테이너 포트를 `8080` 으로 바꾼다.

적용 **전에** 오버레이를 stdout으로 렌더링해 확인한 뒤 적용한다.

## 모범 풀이

```bash
kubectl create namespace prod-web
mkdir -p /opt/course/q02/overlays/prod
```

`/opt/course/q02/overlays/prod/port-patch.yaml`:

```yaml
- op: replace
  path: /spec/template/spec/containers/0/ports/0/containerPort
  value: 8080
```

`/opt/course/q02/overlays/prod/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: prod-web
namePrefix: prod-
labels:
  - pairs:
      env: prod
    includeSelectors: false
resources:
  - ../../base
replicas:
  - name: web
    count: 4
images:
  - name: nginx
    newTag: "1.27"
configMapGenerator:
  - name: web-config
    literals:
      - TIER=prod
      - LOG_LEVEL=warn
patches:
  - target:
      kind: Deployment
      name: web
    path: port-patch.yaml
```

```bash
kubectl kustomize /opt/course/q02/overlays/prod     # 렌더만, 적용하지 않음
kubectl apply -k /opt/course/q02/overlays/prod
```

두 가지가 사람을 넘어뜨립니다. 첫째, `replicas` / `images` / `patches` 의 `name` 은
**접두사가 붙기 전의 원래 이름**(`web`)입니다. `prod-web` 으로 쓰면 매칭이 안 되고 조용히
무시됩니다. 둘째, 구식 `commonLabels` 를 쓰면 레이블이 Deployment의 `selector.matchLabels` 와
Service의 `selector` 에도 함께 주입됩니다. 셀렉터는 불변 필드라서 이미 존재하는 Deployment에
apply하면 거부됩니다. 신형 `labels` 필드는 `includeSelectors` 가 기본 false라 메타데이터에만
붙습니다 — 그래서 `commonLabels` 대신 `labels` 를 쓰는 것이 안전합니다.

`configMapGenerator` 가 만드는 ConfigMap 이름에는 내용 해시 접미사가 붙어
`prod-web-config-8fc6m2kdtt` 같은 형태가 됩니다. 이는 의도된 동작입니다 — 내용이 바뀌면
이름이 바뀌어 파드가 롤아웃됩니다. 해시가 싫으면 `generatorOptions.disableNameSuffixHash: true`.

## 검증

```bash
kubectl -n prod-web get deploy,svc,cm
# deployment.apps/prod-web   4/4
# service/prod-web
# configmap/prod-web-config-<hash>

kubectl -n prod-web get deploy prod-web \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'   # nginx:1.27

kubectl -n prod-web get deploy prod-web \
  -o jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}{"\n"}'  # 8080

kubectl -n prod-web get all --show-labels | grep env=prod
kubectl kustomize /opt/course/q02/overlays/prod | grep -c 'env: prod'
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 오버레이 안의 `name:` 은 항상 베이스의 원래 이름을 가리킨다. `namePrefix` 는 마지막에 적용된다.
- **헷갈리는 지점**: `kubectl kustomize <dir>` 는 렌더만 하고 클러스터를 건드리지 않습니다.
  `kubectl apply -k <dir>` 가 적용입니다. `-f` 와 `-k` 를 섞어 쓰면
  (`kubectl apply -f overlays/prod/`) kustomization.yaml을 일반 매니페스트로 읽으려다 실패합니다.

## 참고 문서

- 검색어: `kustomize declarative management`
- https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
