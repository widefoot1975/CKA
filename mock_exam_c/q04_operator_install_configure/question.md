# q04 — Install and configure an operator

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

<details><summary>명령어 펼치기 — 번들 매니페스트 전체가 보이니 풀기 전에는 읽지 않는 것을 권장</summary>

```bash
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
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후에는 `/opt/course/q04/operator.yaml` 파일만 있고 클러스터에는 아무것도 설치되지 않았다. 설치는 문제 1번에서 한다.
번들의 컨트롤러는 진짜 오퍼레이터가 아니라 `curlimages/curl:8.10.1` 컨테이너가 10초마다 API 서버에 `backups` 를 list 하고, 새 `Backup` 을 보면 로그를 남기고 `status.phase` 를 `Scheduled` 로 채우는 흉내만 낸다.
권한이 없으면 로그에 API 서버의 거부 메시지가 그대로 찍힌다. 문제에 적힌 메시지는 그 줄을 줄여 쓴 것이다.

<details><summary>setup 이 심어 둔 고장 (스포일러)</summary>

번들의 ClusterRole `backup-operator` 에서 `backups`·`backups/status` 규칙의 `apiGroups` 가 `telco.io` 가 아니라 core 그룹 `""` 로 적혀 있다(바로 위 `events` 규칙을 복사해 쓴 실수). ClusterRoleBinding 의 subject 는 맞다.
`cleanup.sh` 는 번들이 만든 것(namespace `backup-system`, CRD, ClusterRole·ClusterRoleBinding `backup-operator`)과 풀이에서 만드는 ClusterRole `backup-viewer`, `default` 의 `viewer-test` ServiceAccount·RoleBinding, `/opt/course/q04` 를 지운다. CRD 를 지우면 `Backup` `nightly` 도 함께 지워진다.

</details>

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns backup-system --ignore-not-found
kubectl delete crd backups.telco.io --ignore-not-found
kubectl delete clusterrolebinding backup-operator --ignore-not-found
kubectl delete clusterrole backup-operator backup-viewer --ignore-not-found
kubectl -n default delete rolebinding viewer-test --ignore-not-found
kubectl -n default delete serviceaccount viewer-test --ignore-not-found
rm -rf /opt/course/q04
```

</details>

## Task

The manifest bundle for a backup operator is at `/opt/course/q04/operator.yaml`. It
contains a Namespace, a CRD, a ServiceAccount, a ClusterRole, a ClusterRoleBinding and
the controller Deployment.

1. Install the bundle. The operator must end up in namespace `backup-system`.
2. Report the full resource name, API group, version, short name and scope of the
   custom resource the CRD registers.
3. The controller Deployment `backup-operator` comes up but its log repeatedly shows
   `backups.telco.io is forbidden: cannot list resource "backups"`. Find the cause and
   fix it. Do not grant `cluster-admin`.
4. Everyone bound to the built-in `view` ClusterRole must also be able to read `backups`.
   Achieve this **without editing the `view` ClusterRole**, using a new ClusterRole named
   `backup-viewer`.
5. Once the controller reconciles cleanly, create a `Backup` named `nightly` in namespace
   `default` with `spec.schedule: "0 2 * * *"` and `spec.target: pvc/data-web-0`, and
   show that the controller observed it.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
