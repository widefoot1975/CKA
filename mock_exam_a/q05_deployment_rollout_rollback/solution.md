# q05 — Deployment rolling update and rollback · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`web` 네임스페이스에서 다음을 수행한다.

1. 이미지 `nginx:1.25`, replicas 4로 Deployment `frontend` 를 만든다.
2. 업데이트 중 **사용 불가 파드가 최대 1개, 초과 생성 파드도 최대 1개**가 되도록 업데이트 전략을 설정한다.
3. 이미지를 `nginx:1.26` 으로 업데이트하고 rollout 상태를 확인한다.
4. 존재하지 않는 태그 `nginx:9.9.9` 로 한 번 더 업데이트해 rollout이 멈추는 것을 확인한 뒤, **마지막으로 정상 동작한 리비전으로 롤백**한다.

## 모범 풀이

```bash
kubectl create namespace web
kubectl -n web create deploy frontend --image=nginx:1.25 --replicas=4
```

**2) 전략 설정** — `maxUnavailable: 1`, `maxSurge: 1`

```bash
kubectl -n web patch deploy frontend -p '{
  "spec": {"strategy": {"type": "RollingUpdate", "rollingUpdate":
    {"maxUnavailable": 1, "maxSurge": 1}}}
}'
```

**3) 업데이트**

```bash
kubectl -n web set image deploy/frontend nginx=nginx:1.26
kubectl -n web rollout status deploy/frontend
```

**4) 실패 유발 후 롤백**

```bash
kubectl -n web set image deploy/frontend nginx=nginx:9.9.9
kubectl -n web rollout status deploy/frontend --timeout=30s   # 멈춤 확인
kubectl -n web get pods                                        # ImagePullBackOff

kubectl -n web rollout history deploy/frontend
kubectl -n web rollout undo deploy/frontend                    # 직전으로
kubectl -n web rollout status deploy/frontend
```

특정 리비전으로 돌아가려면 `kubectl rollout undo deploy/frontend --to-revision=2`.

컨테이너 이름은 `kubectl create deploy` 로 만들면 이미지 이름에서 따옵니다(`nginx`). `set image` 의 `<컨테이너이름>=<이미지>` 에서 이걸 틀리면 조용히 실패합니다 — `kubectl -n web get deploy frontend -o jsonpath='{.spec.template.spec.containers[*].name}'` 로 확인하세요.

## 검증

```bash
kubectl -n web get deploy frontend -o jsonpath='{.spec.strategy.rollingUpdate}'; echo
kubectl -n web get deploy frontend -o jsonpath='{.spec.template.spec.containers[0].image}'; echo   # nginx:1.26
kubectl -n web get pods                         # 4개 Running
kubectl -n web rollout history deploy/frontend
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `rollout undo` 는 직전 리비전. 여러 번 잘못 배포했으면 `rollout history` 로 리비전 번호를 보고 `--to-revision` 지정.
- **헷갈리는 지점**: `maxUnavailable`/`maxSurge` 는 `spec.strategy.rollingUpdate` 아래. 필드 경로가 기억나지 않으면 `kubectl explain deploy.spec.strategy.rollingUpdate`.

## 참고 문서

- 검색어: `rolling update deployment`
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-update-deployment

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
