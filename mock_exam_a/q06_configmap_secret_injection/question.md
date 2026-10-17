# q06 — Configure an application with a ConfigMap and Secret

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리 — 이 문제가 만드는 오브젝트만 지운다 (namespace 는 남김)
if kubectl get ns web >/dev/null 2>&1; then
  kubectl -n web delete pod web-app --ignore-not-found --wait=true
  kubectl -n web delete configmap app-config app-files --ignore-not-found
  kubectl -n web delete secret db-cred --ignore-not-found
fi

# 1) namespace web 준비 (문제는 web 이 이미 있다고 가정한다)
kubectl create ns web --dry-run=client -o yaml | kubectl apply -f -

# 2) 노드가 nginx 이미지를 받을 수 있는지 미리 확인 (오프라인 실습 환경 대비)
kubectl run img-check --image=nginx:1.27 --restart=Never --rm -i --pod-running-timeout=2m -- nginx -v || \
  echo "nginx 이미지를 받지 못함 — 레지스트리 접근을 먼저 확인할 것"

# 3) 시작 상태 확인: web-app / app-config / app-files / db-cred 가 없어야 함
kubectl -n web get pod,configmap,secret
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

이 문제는 ConfigMap·Secret·Pod 를 모두 직접 만드는 것부터 시작하므로, setup 은 빈 namespace `web` 을 준비하고
nginx 이미지를 받을 수 있는지만 확인한다. 설정 직후 `web` 에는 이 문제의 오브젝트(`web-app`, `app-config`, `app-files`, `db-cred`)가 하나도 없다.

`web` 은 mock_exam_a/q09, mock_exam_b/q05, mock_exam_f/q06 도 쓰는 namespace 다. 특히 f06 도 `app-config` 를 만들므로
두 문제를 동시에 풀지 않는다. 정리할 때는 이 문제의 오브젝트만 지우고, `web` 이 비었을 때만 namespace 를 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
if kubectl get ns web >/dev/null 2>&1; then
  kubectl -n web delete pod web-app --ignore-not-found --wait=true
  kubectl -n web delete configmap app-config app-files --ignore-not-found
  kubectl -n web delete secret db-cred --ignore-not-found

  left=$(kubectl -n web get all,ingress,pvc,configmap,secret -o name 2>/dev/null \
           | grep -v '^configmap/kube-root-ca.crt$' || true)
  if [ -z "$left" ]; then
    kubectl delete ns web
  else
    echo "namespace web 에 다른 리소스가 남아 있어 namespace 는 지우지 않음:"
    echo "$left"
  fi
fi
```

</details>

## Task

An application in namespace `web` takes its settings from the cluster, not from its image.

1. Create a ConfigMap `app-config` with `APP_MODE=production` and `LOG_LEVEL=warn`.
2. Create a ConfigMap `app-files` with key `app.properties` = `timeout=30\nretries=3`.
3. Create a generic Secret `db-cred` with `username=appuser` and `password=S3cr3t!`.
4. Create a Pod `web-app` running `nginx:1.27` that
   - receives every key of `app-config` as an environment variable in one block
   - receives only the `password` key of `db-cred` as the variable `DB_PASSWORD`
   - mounts `db-cred` read-only at `/etc/db`
   - mounts `app.properties` at `/etc/nginx/app.properties` without hiding the image's own
     files in `/etc/nginx`
5. Show the variables and the mounted files from inside the container, and state in one
   line why the `/etc/nginx/app.properties` mount will not see a later edit of `app-files`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
