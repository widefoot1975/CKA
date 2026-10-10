# q03 — Explore installed CRDs with kubectl

| Item | Value |
|---|---|
| Exam | mock_exam_d |
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
# 0) 이전 실습 결과 파일 정리
rm -rf /opt/course/d03

# 1) cert-manager 설치 (이미 있으면 그대로 유지)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
kubectl wait --for=condition=Established crd/certificates.cert-manager.io --timeout=120s
kubectl -n cert-manager wait --for=condition=Available deploy --all --timeout=180s

# 2) 결과 파일 디렉터리
mkdir -p /opt/course/d03

# 3) 설정 확인
kubectl get crd | grep cert-manager.io
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `kubectl get crd | grep cert-manager.io` 에 cert-manager CRD 6개가 보이고, `/opt/course/d03/` 는 비어 있다.
`cleanup.sh` 는 결과 파일만 지운다. cert-manager 까지 지우려면 스크립트의 주석을 해제한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
rm -rf /opt/course/d03
# cert-manager 까지 지우려면 아래 주석을 해제 (다른 문제에서 쓰면 남겨 둘 것)
# kubectl delete -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml --ignore-not-found
```

</details>

## Task

cert-manager is installed in the cluster. Using only `kubectl`, collect information about the
custom resources it added.

1. Write the names of all CustomResourceDefinitions whose API group ends with `cert-manager.io`
   to `/opt/course/d03/crds.txt`, one name per line (for example `certificates.cert-manager.io`).
2. Write the `kubectl explain` documentation of the field `spec.renewBefore` of the
   `Certificate` resource to `/opt/course/d03/renewbefore.txt`.
3. Write the short names of the `certificates` resource to `/opt/course/d03/shortnames.txt`,
   one per line.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
