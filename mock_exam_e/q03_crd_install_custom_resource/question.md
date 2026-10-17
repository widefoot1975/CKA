# q03 — Install a CRD and create a custom resource

| Item | Value |
|---|---|
| Exam | mock_exam_e |
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
# 0) 이전 실습 흔적 정리 (CRD 를 지우면 Widget 오브젝트도 모두 지워진다)
kubectl delete crd widgets.demo.example.com --ignore-not-found --wait=true
rm -rf /opt/course/e03
mkdir -p /opt/course/e03

# 1) 문제에서 설치할 CRD 파일
cat <<'YAML' > /opt/course/e03/crd.yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: widgets.demo.example.com
spec:
  group: demo.example.com
  scope: Namespaced
  names:
    plural: widgets
    singular: widget
    kind: Widget
    shortNames: ["wd"]
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              color: {type: string}
              size: {type: integer}
YAML

# 2) 시작 상태 확인: 파일은 있고 CRD 는 아직 설치되지 않아야 한다
ls -l /opt/course/e03/
kubectl get crd widgets.demo.example.com 2>/dev/null || echo "CRD widgets.demo.example.com 아직 없음 (정상)"
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/e03/crd.yaml` 만 있고 CRD `widgets.demo.example.com` 은 아직 설치되지 않았다. `apiversion.txt` 는 문제에서 직접 만든다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete crd widgets.demo.example.com --ignore-not-found
rm -rf /opt/course/e03
```

</details>

## Task

The file `/opt/course/e03/crd.yaml` contains a CustomResourceDefinition for
`widgets.demo.example.com`.

1. Install the CRD and confirm that the API server now serves the resource in API group
   `demo.example.com`.
2. In namespace `default`, create a `Widget` named `blue-small` with `spec.color: blue` and
   `spec.size: 1`.
3. List the Widgets in `default` using the resource's short name.
4. Write the `apiVersion` you used for the Widget to `/opt/course/e03/apiversion.txt`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
