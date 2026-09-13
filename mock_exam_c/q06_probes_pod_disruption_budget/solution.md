# q06 — Probes and a PodDisruptionBudget · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `shop` 에 `nginx:1.27` 3 레플리카의 Deployment `api` 가 있다. 레이블은 `app=api`,
포트 80으로 서비스한다.

1. startup probe를 추가한다: 포트 80에 HTTP GET `/`, 기동에 최대 60초 허용, 5초마다 검사.
2. readiness probe를 추가한다: 포트 80에 HTTP GET `/healthz`, 5초마다, `failureThreshold: 2`.
3. liveness probe를 추가한다: 포트 80 TCP 소켓, `periodSeconds: 10`, `failureThreshold: 3`.
4. `app=api` 에 대해 최소 2개 파드를 유지하는 PodDisruptionBudget `api-pdb` 를 만든다.
5. nginx 이미지에 `/healthz` 가 없으므로 readiness는 실패한다. Service `api` 의 엔드포인트에
   미치는 영향을 보이고, 존재하는 경로로 프로브를 바꿔 readiness를 통과시킨다.
6. `api` 파드 2개가 있는 노드에 `kubectl drain` 을 시도하고 PDB가 무엇을 하는지 보고한다.

## 모범 풀이

```bash
kubectl -n shop edit deploy api
```

컨테이너 스펙에 넣습니다:

```yaml
        startupProbe:
          httpGet:
            path: /
            port: 80
          periodSeconds: 5
          failureThreshold: 12          # 5초 × 12 = 60초
        readinessProbe:
          httpGet:
            path: /healthz             # 5단계에서 / 로 고친다
            port: 80
          periodSeconds: 5
          failureThreshold: 2
        livenessProbe:
          tcpSocket:
            port: 80
          periodSeconds: 10
          failureThreshold: 3
```

"60초 허용"을 `initialDelaySeconds: 60` 으로 쓰면 안 됩니다. startup probe에서 총 허용 시간은
`periodSeconds × failureThreshold` 입니다. 60 ÷ 5 = 12.

```bash
kubectl create poddisruptionbudget api-pdb -n shop --selector=app=api --min-available=2
```

**5) readiness 실패의 효과**

```bash
kubectl -n shop get pods -l app=api      # READY 0/1, STATUS는 Running (Error가 아니다)
kubectl -n shop describe pod <api-xxx> | grep -A3 Readiness
# Readiness probe failed: HTTP probe failed with statuscode: 404
kubectl -n shop get endpointslice -l kubernetes.io/service-name=api -o yaml | grep -i ready
kubectl -n shop get ep api               # ENDPOINTS <none>
```

readiness가 실패하면 컨테이너는 **재시작되지 않습니다**. 파드가 Endpoints/EndpointSlice에서
빠져 서비스 트래픽만 끊깁니다. `RESTARTS` 가 0인데 `READY 0/1` 이면 readiness 문제입니다.
반대로 liveness가 실패하면 kubelet이 컨테이너를 죽여 `RESTARTS` 가 올라갑니다. 이 구분이
이 문제의 핵심입니다.

```bash
kubectl -n shop patch deploy api --type=json -p='[
  {"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/"}
]'
```

**6) drain과 PDB**

```bash
kubectl get pods -n shop -o wide                  # 파드 2개가 있는 노드 확인
kubectl drain worker01 --ignore-daemonsets --delete-emptydir-data
```

drain은 첫 파드를 축출한 뒤 두 번째에서 멈추고 다음을 반복 출력합니다:

```
error when evicting pods/"api-xxxxx" -n "shop" (will retry after 5s):
Cannot evict pod as it would violate the pod's disruption budget.
```

3개 중 1개를 내리면 2개가 남아 `minAvailable: 2` 를 만족하지만, 두 번째를 내리면 1개가 되어
위반합니다. 다른 노드에 대체 파드가 Ready가 되면 drain이 스스로 진행됩니다. 노드가 하나뿐이면
영구히 막히므로 `kubectl -n shop delete pdb api-pdb` 로 풀어야 합니다.

## 검증

```bash
kubectl -n shop get pods -l app=api        # 3/3 READY 1/1, RESTARTS 0
kubectl -n shop get ep api                 # 파드 IP 3개
kubectl -n shop get pdb api-pdb
# NAME     MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
# api-pdb  2               N/A               1

kubectl -n shop get deploy api -o jsonpath='{.spec.template.spec.containers[0].startupProbe}{"\n"}'
kubectl uncordon worker01
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: liveness = 재시작, readiness = Endpoints에서 제외, startup = 나머지 둘을 지연시킴.
- **헷갈리는 지점**: PDB는 **자발적 중단**(`drain`, eviction API)만 막습니다. 노드가 죽거나
  `kubectl delete pod` 로 직접 지우는 것은 PDB를 통과합니다. `ALLOWED DISRUPTIONS` 가 0이면
  drain이 무한 재시도하므로, 시험 중에 노드를 비워야 하는 문제와 PDB 문제가 겹치면 순서를 조심해야 합니다.

## 참고 문서

- 검색어: `configure liveness readiness startup probes`
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
- https://kubernetes.io/docs/tasks/run-application/configure-pdb/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
