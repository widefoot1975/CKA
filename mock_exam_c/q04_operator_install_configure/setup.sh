#!/usr/bin/env bash
# c04 — Install and configure an operator · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (번들이 만든 것 + 풀이에서 만드는 것)
kubectl delete ns backup-system --ignore-not-found --wait=true
kubectl delete crd backups.telco.io --ignore-not-found
kubectl delete clusterrolebinding backup-operator --ignore-not-found
kubectl delete clusterrole backup-operator backup-viewer --ignore-not-found
kubectl -n default delete rolebinding viewer-test --ignore-not-found
kubectl -n default delete serviceaccount viewer-test --ignore-not-found
rm -rf /opt/course/q04

# 1) 오퍼레이터 번들을 파일로만 만든다 (설치는 문제에서 한다)
#    컨트롤러는 curl 로 API 서버에서 backups 를 주기적으로 list 하고, 새 Backup 의 status.phase 를 채우는 흉내만 낸다.
mkdir -p /opt/course/q04
cat > /opt/course/q04/operator.yaml <<'YAML'
apiVersion: v1
kind: Namespace
metadata:
  name: backup-system
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: backups.telco.io
spec:
  group: telco.io
  scope: Namespaced
  names:
    plural: backups
    singular: backup
    kind: Backup
    shortNames: ["bk"]
  versions:
  - name: v1alpha1
    served: true
    storage: true
    subresources:
      status: {}
    additionalPrinterColumns:
    - {name: Schedule, type: string, jsonPath: .spec.schedule}
    - {name: Target, type: string, jsonPath: .spec.target}
    - {name: Phase, type: string, jsonPath: .status.phase}
    - {name: Age, type: date, jsonPath: .metadata.creationTimestamp}
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            required: ["schedule", "target"]
            properties:
              schedule:
                type: string
                description: Cron expression for when the backup runs.
              target:
                type: string
                description: What to back up, as <kind>/<name>, e.g. pvc/data-web-0.
          status:
            type: object
            properties:
              phase:
                type: string
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: backup-operator
  namespace: backup-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: backup-operator
rules:
- apiGroups: [""]
  resources: ["events"]
  verbs: ["create", "patch"]
- apiGroups: [""]
  resources: ["backups", "backups/status"]
  verbs: ["get", "list", "watch", "update", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: backup-operator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: backup-operator
subjects:
- kind: ServiceAccount
  name: backup-operator
  namespace: backup-system
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backup-operator
  namespace: backup-system
  labels: {app: backup-operator}
spec:
  replicas: 1
  selector:
    matchLabels: {app: backup-operator}
  template:
    metadata:
      labels: {app: backup-operator}
    spec:
      serviceAccountName: backup-operator
      containers:
      - name: manager
        image: curlimages/curl:8.10.1
        command: ["/bin/sh", "-c"]
        args:
        - |
          API=https://kubernetes.default.svc
          SA=/var/run/secrets/kubernetes.io/serviceaccount
          log() { echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) $*"; }
          k() { curl -s --cacert $SA/ca.crt -H "Authorization: Bearer $(cat $SA/token)" -w '\n%{http_code}' "$@"; }
          msg() { sed -n 's/.*"message":"\(.*\)","reason".*/\1/p' | sed 's/\\"/"/g'; }
          seen=" "; synced=0
          log "backup-operator v0.3.1 starting, watching backups.telco.io/v1alpha1"
          while true; do
            out=$(k $API/apis/telco.io/v1alpha1/backups)
            body=$(echo "$out" | sed '$d')
            if [ "$(echo "$out" | tail -n1)" != 200 ]; then
              log "ERROR failed to list *v1alpha1.Backup: $(echo "$body" | msg)"
              synced=0; sleep 10; continue
            fi
            items=$(echo "$body" | grep -o '"name":"[^"]*","namespace":"[^"]*"' \
              | sed 's#"name":"\([^"]*\)","namespace":"\([^"]*\)"#\2/\1#')
            if [ $synced = 0 ]; then
              log "cache synced, $(echo "$items" | grep -c /) Backup(s)"; synced=1
            fi
            for item in $items; do
              case "$seen" in *" $item "*) continue ;; esac
              log "Reconciling Backup $item"
              r=$(k -X PATCH -H 'Content-Type: application/merge-patch+json' \
                -d '{"status":{"phase":"Scheduled"}}' \
                $API/apis/telco.io/v1alpha1/namespaces/${item%%/*}/backups/${item#*/}/status)
              if [ "$(echo "$r" | tail -n1)" = 200 ]; then
                log "Backup $item scheduled"; seen="$seen$item "
              else
                log "ERROR failed to update status of Backup $item: $(echo "$r" | sed '$d' | msg)"
              fi
            done
            sleep 10
          done
YAML

# 2) 시작 상태 확인: 번들 파일만 있고 클러스터에는 아무것도 설치되지 않았다
ls -l /opt/course/q04/
kubectl get crd backups.telco.io 2>&1 || true
kubectl get ns backup-system 2>&1 || true
