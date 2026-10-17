# q03 — Manage a cluster component with Helm

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) helm 이 설치되어 있는지 확인 (없으면 여기서 멈춘다)
helm version --short

# 1) 기존 cert-manager 제거: Helm 릴리스 → kubectl 매니페스트 설치분 → 남은 CRD 순서
if helm status cert-manager -n cert-manager >/dev/null 2>&1; then
  helm uninstall cert-manager -n cert-manager --wait
fi
if kubectl -n cert-manager get deploy cert-manager >/dev/null 2>&1; then
  kubectl delete -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml --ignore-not-found
fi
CRDS=$(kubectl get crd -o name | grep 'cert-manager\.io$' || true)
if [ -n "$CRDS" ]; then
  kubectl delete $CRDS --wait=true      # crds.keep=true 로 남은 CRD 까지 지운다
fi
kubectl delete ns cert-manager --ignore-not-found --wait=true

# 2) 저장소와 결과 파일 정리
helm repo remove jetstack >/dev/null 2>&1 || true
rm -rf /root/helm
mkdir -p /root/helm

# 3) 시작 상태 확인: cert-manager 의 흔적이 없어야 한다
kubectl get crd | grep cert-manager.io || echo "cert-manager CRD 없음 (정상)"
helm list -A | grep cert-manager || echo "cert-manager 릴리스 없음 (정상)"
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 클러스터에 cert-manager(릴리스·CRD·namespace)가 하나도 없고, `jetstack` 저장소도 없으며 `/root/helm/` 은 비어 있다.
**주의:** 이 setup 은 `mock_exam_d/q03` 이 쓰는 cert-manager 도 지운다. d03 을 다시 풀 때는 d03 의 setup 을 다시 돌리면 된다(이 문제의 Helm 설치가 남아 있으면 d03 setup 은 그대로 쓴다).
차트와 이미지를 받아야 하므로 `charts.jetstack.io` 와 `quay.io` 로 인터넷 연결이 되어야 한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
if helm status cert-manager -n cert-manager >/dev/null 2>&1; then
  helm uninstall cert-manager -n cert-manager --wait
fi
# crds.keep=true(기본) 라서 uninstall 뒤에도 CRD 가 남는다 — 직접 지운다
CRDS=$(kubectl get crd -o name | grep 'cert-manager\.io$' || true)
if [ -n "$CRDS" ]; then
  kubectl delete $CRDS
fi
kubectl delete ns cert-manager --ignore-not-found
helm repo remove jetstack >/dev/null 2>&1 || true
rm -rf /root/helm
```

</details>

## Task

Use Helm to install cert-manager as a cluster component in namespace `cert-manager`.
Write every answer file under `/root/helm/`.

1. Add the chart repository `jetstack` at `https://charts.jetstack.io`, refresh the index,
   and write the latest version of chart `jetstack/cert-manager` to
   `/root/helm/version.txt`. Pass exactly that version with `--version` in every later step.
2. Save the chart's default values to `/root/helm/values.yaml` **without installing
   anything**, and write the names of the values that control CRD installation to
   `/root/helm/crd-values.txt`.
3. Install release `cert-manager` into `cert-manager`, creating the namespace, with the
   CRDs installed by the chart and the controller running `2` replicas.
4. Upgrade the release so the controller runs `3` replicas **without losing any value set
   in step 3**. Show the release history, roll back to revision 1, and confirm the
   controller is back to 2 replicas and the CRDs still exist.
5. Using only `kubectl`, write the documentation of the field `spec.dnsNames` of the
   `Certificate` resource to `/root/helm/dnsnames.txt`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
