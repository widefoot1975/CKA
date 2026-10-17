# q03 — Install a CRD and create a custom resource

| Item | Value |
|---|---|
| Exam | mock_exam_b |
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
# 0) 이전 실습 흔적 정리 (그룹 training.example.com 의 CRD 를 지우면 Exercise 오브젝트도 모두 지워진다)
for c in $(kubectl get crd -o jsonpath='{range .items[?(@.spec.group=="training.example.com")]}{.metadata.name}{"\n"}{end}'); do
  kubectl delete crd "$c" --wait=true
done
kubectl delete ns cka --ignore-not-found --wait=true
rm -rf /opt/q03

# 1) 문제에서 쓸 namespace 와 답 파일 디렉터리
kubectl create ns cka
mkdir -p /opt/q03

# 2) 시작 상태 확인: namespace 와 디렉터리는 있고, 그룹 training.example.com 은 아직 서비스되지 않아야 한다
kubectl get ns cka
ls -ld /opt/q03
kubectl api-resources --api-group=training.example.com
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `cka` 와 빈 디렉터리 `/opt/q03` 만 있다. CRD 는 아직 없어서 마지막 `kubectl api-resources` 는 머리글만 출력한다. CRD 와 `Exercise`, `crd.txt` 는 문제에서 직접 만든다.
CRD 이름을 적으면 `metadata.name` 형식이라는 답이 드러나므로, 스크립트는 이름 대신 그룹(`training.example.com`)으로 CRD 를 찾아 지운다. namespace `cka` 는 이 문제만 쓴다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
for c in $(kubectl get crd -o jsonpath='{range .items[?(@.spec.group=="training.example.com")]}{.metadata.name}{"\n"}{end}'); do
  kubectl delete crd "$c"
done
kubectl delete ns cka --ignore-not-found
rm -rf /opt/q03
```

</details>

## Task

A training team wants to track drills as first-class Kubernetes objects.

1. Create a CustomResourceDefinition with group `training.example.com`, version `v1`,
   scope `Namespaced`, kind `Exercise`, plural `exercises`, singular `exercise` and
   short name `ex`.
2. The schema must accept `spec.topic` (string, **required**) and `spec.minutes`
   (integer, default `30`). Any other field under `spec` must not be stored.
3. Add two additional printer columns so `kubectl get exercises` shows `TOPIC`
   (`.spec.topic`) and `MINUTES` (`.spec.minutes`).
4. In namespace `cka`, create an `Exercise` named `networkpolicy-drill` with
   `topic: networking` and no `minutes` field.
5. Write the API group/version that serves this resource, and the value `minutes` ended
   up with, to `/opt/q03/crd.txt`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
