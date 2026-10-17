#!/usr/bin/env bash
# e03 — Install a CRD and create a custom resource · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

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
