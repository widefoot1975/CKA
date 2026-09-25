# q03 — Explore installed CRDs with kubectl · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

클러스터에 cert-manager가 설치되어 있다. `kubectl` 만 써서 cert-manager가 추가한 커스텀 리소스의
정보를 모은다.

1. API 그룹이 `cert-manager.io` 로 끝나는 모든 CustomResourceDefinition의 이름을 한 줄에 하나씩
   `/opt/course/d03/crds.txt` 에 적는다(예: `certificates.cert-manager.io`).
2. `Certificate` 리소스의 필드 `spec.renewBefore` 에 대한 `kubectl explain` 문서를
   `/opt/course/d03/renewbefore.txt` 에 쓴다.
3. `certificates` 리소스의 짧은 이름(short name)을 한 줄에 하나씩 `/opt/course/d03/shortnames.txt` 에 적는다.

## 모범 풀이

**1) CRD 이름과 그룹**

```bash
mkdir -p /opt/course/d03
kubectl get crd -o custom-columns=NAME:.metadata.name,GROUP:.spec.group
# NAME                                  GROUP
# certificaterequests.cert-manager.io   cert-manager.io
# certificates.cert-manager.io          cert-manager.io
# challenges.acme.cert-manager.io       acme.cert-manager.io
# clusterissuers.cert-manager.io        cert-manager.io
# issuers.cert-manager.io               cert-manager.io
# orders.acme.cert-manager.io           acme.cert-manager.io
# ...  (다른 CRD가 있으면 함께 나온다)

kubectl get crd --no-headers -o custom-columns=NAME:.metadata.name,GROUP:.spec.group \
  | awk '$2 ~ /cert-manager\.io$/ {print $1}' > /opt/course/d03/crds.txt
```

**CRD의 이름은 항상 `<복수형>.<그룹>` 입니다.** API 서버가 이 형식을 강제하므로 이름의 끝이 곧 그룹입니다.
그래서 `kubectl get crd -o name | grep 'cert-manager\.io$'` 로도 찾을 수 있습니다(이때는 앞에 붙는
`customresourcedefinition.apiextensions.k8s.io/` 를 잘라 내야 합니다). `acme.cert-manager.io` 그룹의
challenges, orders 도 "cert-manager.io 로 끝나는" 그룹이므로 빠뜨리지 않습니다.

**2) 필드 문서 — `kubectl explain`**

```bash
kubectl explain certificates.spec.renewBefore > /opt/course/d03/renewbefore.txt
```

CRD가 OpenAPI 스키마를 제공하면 `kubectl explain` 이 내장 리소스와 똑같이 동작합니다. 리소스 이름은
복수형·단수형·짧은 이름이 모두 되지만, 필드 경로는 대소문자를 구분합니다(`renewbefore` 는 실패).
하위 필드를 한꺼번에 보려면 `kubectl explain certificates.spec --recursive` 입니다.

**3) 짧은 이름 — `kubectl api-resources`**

```bash
kubectl api-resources --api-group=cert-manager.io
# NAME                  SHORTNAMES   APIVERSION           NAMESPACED   KIND
# certificaterequests   cr,crs       cert-manager.io/v1   true         CertificateRequest
# certificates          cert,certs   cert-manager.io/v1   true         Certificate
# clusterissuers                     cert-manager.io/v1   false        ClusterIssuer
# issuers                            cert-manager.io/v1   true         Issuer

printf 'cert\ncerts\n' > /opt/course/d03/shortnames.txt       # SHORTNAMES 열에서 읽은 값 그대로
kubectl get crd certificates.cert-manager.io -o jsonpath='{.spec.names.shortNames}{"\n"}'   # 교차 확인
```

`api-resources` 한 화면에 이름, 짧은 이름, 그룹/버전, 네임스페이스 범위, Kind가 모두 나옵니다. 처음 보는
CRD를 만나면 가장 먼저 칠 명령입니다.

## 검증

```bash
cat /opt/course/d03/crds.txt          # cert-manager 기본 설치라면 6줄
head -5 /opt/course/d03/renewbefore.txt
# GROUP:      cert-manager.io
# KIND:       Certificate
# VERSION:    v1
#
# FIELD: renewBefore <string>
cat /opt/course/d03/shortnames.txt    # cert, certs
kubectl get certs -A                  # 짧은 이름이 실제로 동작한다
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: CRD 이름 = `<plural>.<group>`. 그룹·버전·짧은 이름은 `kubectl api-resources --api-group=<그룹>`, 필드 문서는 `kubectl explain <리소스>.<필드경로>`.
- **헷갈리는 지점**: `kubectl get crd` 가 보여 주는 것은 "리소스 종류의 정의"이고, 실제 오브젝트는 `kubectl get certificates -A` 로 봅니다. 같은 이름의 리소스가 여러 그룹에 있으면 `kubectl explain` 에 `--api-version=cert-manager.io/v1` 을 붙여 그룹을 지정합니다.

## 참고 문서

- 검색어: `custom resource definitions`, `kubectl explain`
- https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/
- https://kubernetes.io/docs/reference/kubectl/quick-reference/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
