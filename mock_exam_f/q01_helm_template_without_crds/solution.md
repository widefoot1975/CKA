# q01 — Render and install a chart without its CRDs · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

Argo CD의 CustomResourceDefinition(`*.argoproj.io`)은 이미 클러스터에 설치되어 있고 Helm 밖에서
관리된다. 이제 Argo CD 자체를 Helm으로 설치하되, 차트가 그 CRD를 만들거나 관리하지 않게 해야 한다.

1. 차트 저장소 `https://argoproj.github.io/argo-helm` 을 `argo` 라는 이름으로 추가한다. `helm search repo`
   가 보여 주는 차트 `argo/argo-cd` 의 최신 버전을 `/opt/course/f01/version.txt` 에 적고, 다음 단계들에서
   정확히 그 버전을 쓴다.
2. `helm template` 으로 차트를 렌더링한다. 릴리스 이름 `argocd`, 네임스페이스 `argocd`, 값
   `crds.install=false` 를 쓰고 출력을 `/opt/course/f01/argocd.yaml` 에 저장한다.
3. 같은 차트 버전과 같은 값으로 릴리스 `argocd` 를 네임스페이스 `argocd` 에 설치한다(네임스페이스도 생성).
4. `/opt/course/f01/argocd.yaml` 에 `kind: CustomResourceDefinition` 이 없고, `helm list -n argocd` 에서
   릴리스가 `deployed` 로 보이는지 확인한다.

## 모범 풀이

**1) 저장소 추가와 버전 고정**

```bash
mkdir -p /opt/course/f01
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm search repo argo/argo-cd
# NAME           CHART VERSION   APP VERSION   DESCRIPTION
# argo/argo-cd   x.y.z           vX.Y.Z        A Helm chart for Argo CD, ...
helm search repo argo/argo-cd | awk 'NR==2{print $2}' > /opt/course/f01/version.txt
VER=$(cat /opt/course/f01/version.txt)
```

**2~3) 렌더링과 설치 — 같은 버전, 같은 값**

```bash
helm show values argo/argo-cd --version $VER | grep -A6 '^crds:'   # CRD 를 제어하는 값 확인
# crds:
#   install: true        ← CRD 설치·업그레이드 여부 (기본 true)
#   keep: true           ← uninstall 때 CRD 를 남길지

helm template argocd argo/argo-cd --version $VER -n argocd \
  --set crds.install=false > /opt/course/f01/argocd.yaml

helm install argocd argo/argo-cd --version $VER -n argocd --create-namespace \
  --set crds.install=false
```

**핵심 — CRD를 끄는 방법은 차트가 CRD를 어디에 두었는지에 따라 다릅니다.**

| 차트 안의 CRD 위치 | Helm 의 처리 | 끄는 방법 |
|---|---|---|
| `crds/` 디렉터리 | `helm install` 때 템플릿보다 먼저 한 번만 설치. 업그레이드·삭제는 하지 않음 | `--skip-crds` 플래그 |
| `templates/` 안의 조건부 템플릿 | 다른 리소스처럼 릴리스에 포함되어 함께 업그레이드됨 | 차트가 제공하는 값 (`crds.install=false`) |

argo-cd 차트는 CRD를 `templates/` 안에 두고 `crds.install` 값으로 감쌉니다. 그래서 이 차트에는
`--skip-crds` 가 아무 효과가 없고 값으로 꺼야 합니다. 반대로 `crds/` 디렉터리 방식의 차트에는 그런 값이
없으니 `--skip-crds` 를 씁니다.

값을 끄지 않고 설치하면 Helm이 이미 있는 CRD를 자기 릴리스에 포함시키려다가
`... exists and cannot be imported into the current release: invalid ownership metadata` 오류로 설치가
실패합니다. 문제의 "CRD는 Helm 밖에서 관리된다"는 조건이 바로 이 값을 꺼야 하는 이유입니다.

## 검증

```bash
cat /opt/course/f01/version.txt                                           # x.y.z
grep -c 'kind: CustomResourceDefinition' /opt/course/f01/argocd.yaml      # 0
helm list -n argocd
# NAME     NAMESPACE   REVISION   UPDATED   STATUS     CHART           APP VERSION
# argocd   argocd      1          ...       deployed   argo-cd-x.y.z   vX.Y.Z
helm get manifest argocd -n argocd | grep -c 'kind: CustomResourceDefinition'   # 0 — 릴리스에 CRD 없음
kubectl get crd | grep argoproj.io      # applications / applicationsets / appprojects — 그대로 있음
kubectl -n argocd get deploy            # 모든 Deployment 가 READY
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: CRD가 `templates/` 에 있는 차트는 값(`crds.install=false`)으로, `crds/` 디렉터리에 있는 차트는 `--skip-crds` 로 끈다. `template` 과 `install` 에 같은 `--version` 과 같은 값을 넘긴다.
- **헷갈리는 지점**: `helm template` 출력에 CRD가 없다고 `helm install` 도 CRD를 건너뛰는 것은 아닙니다. `crds/` 디렉터리의 CRD는 `helm template` 에서는 기본으로 빠지고(`--include-crds` 를 줘야 나옴) `helm install` 에서는 기본으로 설치됩니다. 차트가 어느 방식인지는 `helm show values` 에 CRD 관련 값이 있는지, `helm pull --untar` 로 받은 차트에 `crds/` 디렉터리가 있는지로 확인합니다.

## 참고 문서

- 검색어: `helm template`, `custom resource definitions`
- https://helm.sh/docs/helm/helm_template/
- https://helm.sh/docs/chart_best_practices/custom_resource_definitions/
- https://helm.sh/docs/topics/charts/#custom-resource-definitions-crds

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
