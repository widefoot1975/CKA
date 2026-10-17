# q01 — Render and install a chart without its CRDs

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
command -v helm >/dev/null || { echo "helm 이 없습니다. https://helm.sh/docs/intro/install/ 로 먼저 설치하세요"; exit 1; }

# 0) 이전 실습 흔적 정리: 릴리스, 네임스페이스, 저장소 등록, 결과 파일, 지난번 CRD
helm uninstall argocd -n argocd 2>/dev/null || true
kubectl delete ns argocd --ignore-not-found --wait=true
helm repo remove argo 2>/dev/null || true
rm -rf /opt/course/f01
kubectl get crd -o name | grep 'argoproj.io' | xargs -r kubectl delete --wait=true

# 1) Argo CD CRD 세 개를 Helm 밖에서 설치 (Helm 라벨·어노테이션이 없는 상태)
#    applicationsets CRD 는 커서 client-side apply 의 어노테이션 크기 제한에 걸리므로 --server-side
BASE=https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds
kubectl apply --server-side \
  -f $BASE/application-crd.yaml \
  -f $BASE/applicationset-crd.yaml \
  -f $BASE/appproject-crd.yaml
kubectl wait crd/applications.argoproj.io crd/applicationsets.argoproj.io crd/appprojects.argoproj.io \
  --for=condition=Established --timeout=60s

# 2) 결과 파일 디렉터리 (비어 있는 상태)
mkdir -p /opt/course/f01

# 3) 시작 상태 확인: CRD 3개는 있고, 저장소 argo 와 릴리스 argocd 는 없다
kubectl get crd | grep argoproj.io
helm repo list 2>/dev/null | grep -w argo || echo "저장소 argo 없음 (정상)"
helm list -A | grep -w argocd || echo "릴리스 argocd 없음 (정상)"
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

`k8s-c1` 에 `helm` 이 설치되어 있고 인터넷에 연결되어 있어야 한다. Argo CD CRD 세 개(`applications`, `applicationsets`, `appprojects` `.argoproj.io`)를 Helm 밖에서 `kubectl apply --server-side` 로 설치하고, 저장소 `argo`·릴리스 `argocd`·네임스페이스 `argocd` 는 지운 상태로 시작한다.
CRD 는 argo-cd `stable` 브랜치에서 받으므로 최신 차트와 버전이 거의 맞는다. `cleanup.sh` 는 릴리스와 CRD 까지 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
helm uninstall argocd -n argocd 2>/dev/null || true
kubectl delete ns argocd --ignore-not-found --wait=true
helm repo remove argo 2>/dev/null || true
kubectl get crd -o name | grep 'argoproj.io' | xargs -r kubectl delete
rm -rf /opt/course/f01
```

</details>

## Task

The Argo CD CustomResourceDefinitions (`*.argoproj.io`) are already installed in the
cluster and are managed outside of Helm. Argo CD itself must now be installed with Helm,
without the chart creating or managing those CRDs.

1. Add the chart repository `https://argoproj.github.io/argo-helm` with the name `argo`.
   Write the latest version of chart `argo/argo-cd` shown by `helm search repo` to
   `/opt/course/f01/version.txt`, and use exactly that version in the next steps.
2. Render the chart with `helm template` using release name `argocd`, namespace `argocd`
   and the value `crds.install=false`. Save the output to `/opt/course/f01/argocd.yaml`.
3. Install release `argocd` into namespace `argocd` (create the namespace) with the same
   chart version and the same value.
4. Confirm that `/opt/course/f01/argocd.yaml` contains no `kind: CustomResourceDefinition`
   and that `helm list -n argocd` shows the release as `deployed`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
