# q03 — Manage a cluster component with Helm · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

Helm으로 cert-manager를 클러스터 컴포넌트로 `cert-manager` 네임스페이스에 설치한다. 답 파일은 모두
`/root/helm/` 아래에 쓴다.

1. `https://charts.jetstack.io` 를 `jetstack` 이라는 이름의 차트 저장소로 추가하고 인덱스를 갱신한 뒤,
   차트 `jetstack/cert-manager` 의 최신 버전을 `/root/helm/version.txt` 에 적는다. 이후 모든 단계에서
   그 버전을 `--version` 으로 정확히 넘긴다.
2. **아무것도 설치하지 않은 채로** 차트의 기본값을 `/root/helm/values.yaml` 에 저장하고, CRD 설치를
   제어하는 값의 이름을 `/root/helm/crd-values.txt` 에 적는다.
3. 릴리스 `cert-manager` 를 `cert-manager` 네임스페이스(함께 생성)에 설치한다. CRD는 차트가
   설치하게 하고, 컨트롤러는 replica `2` 로 돌린다.
4. **3번에서 지정한 값을 하나도 잃지 않으면서** 컨트롤러를 replica `3` 으로 업그레이드한다. 릴리스
   히스토리를 보고, 리비전 1로 롤백한 뒤 컨트롤러가 다시 2개이고 CRD가 그대로 있는지 확인한다.
5. `kubectl` 만 써서 `Certificate` 리소스의 `spec.dnsNames` 필드 문서를 `/root/helm/dnsnames.txt` 에 쓴다.

## 모범 풀이

**1) 저장소와 버전 고정**

```bash
mkdir -p /root/helm
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm search repo jetstack/cert-manager               # CHART VERSION 열이 최신 버전
helm search repo jetstack/cert-manager --versions | head -5   # 전체 목록이 필요할 때

helm search repo jetstack/cert-manager | awk 'NR==2{print $2}' > /root/helm/version.txt
VER=$(cat /root/helm/version.txt)                    # 예: v1.21.2
```

버전을 고정하지 않으면 채점 시점과 풀이 시점의 "최신"이 달라질 수 있고, 업그레이드·롤백이 다른 차트
버전끼리 섞입니다. 문제에 버전이 있으면 반드시 `--version` 으로 넘깁니다.

**2) 설치 없이 값만 보기 — CRD 관련 값 찾기**

```bash
helm show values jetstack/cert-manager --version $VER > /root/helm/values.yaml
grep -n -A12 '^crds:' /root/helm/values.yaml         # crds.enabled (기본 false), crds.keep (기본 true)
grep -n 'installCRDs' /root/helm/values.yaml         # 예전 이름 — deprecated
printf 'crds.enabled\ncrds.keep\n' > /root/helm/crd-values.txt
```

| 값 | 기본 | 뜻 |
|---|---|---|
| `crds.enabled` | `false` | 차트가 CRD를 설치·관리할지 |
| `crds.keep` | `true` | CRD에 `helm.sh/resource-policy: keep` 을 붙여 릴리스에서 빠져도 지우지 않음 |
| `installCRDs` | `false` | 예전 이름(`crds.enabled=true` + `crds.keep=true` 와 같음). deprecated |

**3) 설치**

```bash
helm install cert-manager jetstack/cert-manager --version $VER \
  --namespace cert-manager --create-namespace \
  --set crds.enabled=true \
  --set replicaCount=2

kubectl get crd | grep cert-manager.io               # certificates, issuers, clusterissuers ...
kubectl -n cert-manager get deploy cert-manager -o jsonpath='{.spec.replicas}{"\n"}'   # 2
```

`replicaCount` 는 컨트롤러(`cert-manager` Deployment)의 replica입니다. webhook과 cainjector는 각각
`webhook.replicaCount`, `cainjector.replicaCount` 입니다. 값 이름이 기억나지 않으면 2번에서 저장한
`values.yaml` 을 grep 합니다.

**4) 업그레이드와 롤백** — `--reuse-values` 가 이 문제의 핵심입니다.

```bash
helm upgrade cert-manager jetstack/cert-manager --version $VER \
  --namespace cert-manager --reuse-values \
  --set replicaCount=3

helm get values cert-manager -n cert-manager        # crds.enabled: true, replicaCount: 3
helm history cert-manager -n cert-manager
helm rollback cert-manager 1 -n cert-manager
```

`--reuse-values` 없이 `--set replicaCount=3` 만 주면 **3번에서 준 `crds.enabled=true` 가 기본값 false로
돌아갑니다.** 그러면 CRD가 릴리스 매니페스트에서 빠집니다. `crds.keep=true`(기본) 덕분에 CRD에
`helm.sh/resource-policy: keep` 이 붙어 있어서 Helm이 지우지는 않지만, 더 이상 이 릴리스가 관리하지
않는 상태가 됩니다. keep이 없었다면 CRD가 삭제되고, **CRD와 함께 모든 Certificate·Issuer 오브젝트가
지워집니다.** Helm으로 CRD를 다루는 차트에서 값을 잃는 것이 위험한 이유입니다. 값 파일로 관리한다면
`-f values.yaml` 로 매번 전체를 넘기는 편이 더 안전합니다.

롤백도 **새 리비전을 만듭니다.** 리비전 1로 되돌리면 히스토리에 리비전 3이 "리비전 1의 내용"으로
추가됩니다. 히스토리가 지워지지 않습니다.

**5) CRD 필드 문서는 `kubectl explain`**

CRD가 구조적 스키마(structural schema)를 제공하면 내장 리소스처럼 `kubectl explain` 이 동작합니다.

```bash
kubectl api-resources --api-group=cert-manager.io    # certificates 의 이름·그룹·버전 확인
kubectl explain certificates.spec.dnsNames > /root/helm/dnsnames.txt
# 같은 이름의 리소스가 다른 그룹에도 있으면 --api-version=cert-manager.io/v1 을 붙인다
```

## 검증

```bash
cat /root/helm/version.txt /root/helm/crd-values.txt
helm list -n cert-manager                    # STATUS deployed, CHART cert-manager-<VER>
helm history cert-manager -n cert-manager    # 리비전 3개, 마지막이 "Rollback to 1"
helm get values cert-manager -n cert-manager # crds.enabled: true, replicaCount: 2
kubectl -n cert-manager get deploy           # cert-manager 2/2, webhook·cainjector 1/1
kubectl get crd certificates.cert-manager.io # 존재
head -5 /root/helm/dnsnames.txt              # FIELD: dnsNames <[]string> ...
```

설치하지 않고 결과 매니페스트만 보고 싶을 때:

```bash
helm template cert-manager jetstack/cert-manager --version $VER -n cert-manager \
  --set crds.enabled=true | grep -c 'kind: CustomResourceDefinition'
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `helm upgrade` 에 `--reuse-values` 를 빼면 이전 `--set` 값이 기본값으로 돌아간다. CRD를 차트가 관리하는 경우 그 결과가 CRD 제거(그리고 모든 커스텀 리소스 삭제)로 이어질 수 있다. 버전은 `--version` 으로 고정한다.
- **헷갈리는 지점**: `helm show values` 는 **차트가 제공하는 기본값**, `helm get values` 는 **이 릴리스에 실제로 적용된 값**입니다. 문제에 "설치 전"이면 `show`, "설치된 릴리스"면 `get`. Helm 4(2025.11)에서도 `--reuse-values` 와 `repo`·`show`·`history`·`rollback` 명령은 그대로이고, `--atomic` 은 `--rollback-on-failure` 로 이름이 바뀌었습니다.

## 참고 문서

CKA 시험 중에는 kubernetes.io 문서와 함께 **helm.sh/docs** 도 열람할 수 있습니다(LF 허용 목록). 그래도
옵션 이름은 `helm upgrade --help` 로 찾는 쪽이 빠릅니다.

- 검색어: `helm upgrade`, `cert-manager helm`
- https://helm.sh/docs/helm/helm_upgrade/
- https://cert-manager.io/docs/installation/helm/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
