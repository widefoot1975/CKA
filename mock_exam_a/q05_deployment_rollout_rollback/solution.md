# q05 — Rolling update, pause and roll back a Deployment · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`apps` 네임스페이스의 웹 계층은 업데이트 중에도 선언한 용량 아래로 내려가면 안 된다.

1. `apps` 에 `nginx:1.25` 4 레플리카짜리 Deployment `web` 을 만들고, 전략을 `maxSurge: 1`, `maxUnavailable: 0` 인 `RollingUpdate` 로 설정한다.
2. `nginx:1.26` 으로 롤아웃하고, rollout history에 change cause가 `bump to 1.26` 으로 보이게 한다.
3. 롤아웃을 pause하고 이미지를 `nginx:1.27` 로 바꾼 뒤, pause 상태에서는 새 ReplicaSet이 스케일업되지 않음을 보인다. 그 다음 resume하고 롤아웃이 끝날 때까지 기다린다.
4. 리비전 히스토리를 출력하고 리비전 1을 들여다본 뒤, `nginx:1.25` 를 돌리던 리비전으로 롤백한다.
5. 현재 이미지와 롤아웃 완료 상태를 확인한다.

## 모범 풀이

```bash
kubectl create namespace apps
kubectl -n apps create deploy web --image=nginx:1.25 --replicas=4
kubectl -n apps patch deploy web -p \
  '{"spec":{"strategy":{"type":"RollingUpdate","rollingUpdate":{"maxSurge":1,"maxUnavailable":0}}}}'
```

`maxUnavailable: 0` + `maxSurge: 1` 은 "새 파드 하나를 먼저 띄워 Ready가 된 뒤에야 낡은 파드 하나를 죽인다"는 뜻입니다. Ready 파드 수가 4 미만으로 절대 내려가지 않습니다. 둘을 모두 0으로 두면 교체할 방법이 없어 롤아웃이 영구히 멈추므로 API가 거부합니다.

```bash
kubectl -n apps set image deploy/web nginx=nginx:1.26
kubectl -n apps annotate deploy/web kubernetes.io/change-cause="bump to 1.26" --overwrite
kubectl -n apps rollout status deploy/web
```

**컨테이너 이름은 Deployment 이름이 아닙니다.** `kubectl create deploy web --image=nginx:1.25` 가 만드는 컨테이너 이름은 이미지에서 딴 `nginx` 입니다. 그래서 `set image deploy/web web=nginx:1.26` 은 그 컨테이너를 못 찾습니다. 이름이 확실치 않으면 먼저 확인하거나 와일드카드를 씁니다.

```bash
kubectl -n apps get deploy web -o jsonpath='{.spec.template.spec.containers[*].name}'
kubectl -n apps set image deploy/web '*=nginx:1.26'     # 모든 컨테이너
```

`--record` 는 제거되었습니다. change cause는 `kubernetes.io/change-cause` 어노테이션으로 직접 넣습니다. 이 어노테이션은 Deployment에 붙으면 현재 리비전의 ReplicaSet으로 복사되어 `rollout history` 의 CHANGE-CAUSE 열에 나옵니다.

**pause / resume**

```bash
kubectl -n apps rollout pause deploy/web
kubectl -n apps set image deploy/web nginx=nginx:1.27
kubectl -n apps get rs -o wide        # 1.27 ReplicaSet이 없거나 DESIRED 0
kubectl -n apps rollout resume deploy/web
kubectl -n apps rollout status deploy/web
```

pause 중에는 파드 템플릿 변경이 오브젝트에는 저장되지만 컨트롤러가 새 ReplicaSet을 스케일업하지 않습니다. 여러 항목을 한 번에 바꿔서 롤아웃을 한 번만 돌리고 싶을 때 쓰는 기능입니다.

**히스토리와 롤백**

```bash
kubectl -n apps rollout history deploy/web
kubectl -n apps rollout history deploy/web --revision=1     # 1.25 확인
kubectl -n apps rollout undo deploy/web --to-revision=1
```

`undo` 를 리비전 번호 없이 쓰면 직전 리비전으로 돌아갑니다. 롤백도 새 리비전 번호를 받습니다 — 리비전 1로 돌아가면 그 내용이 리비전 4 등으로 다시 기록됩니다.

## 검증

```bash
kubectl -n apps rollout status deploy/web
# deployment "web" successfully rolled out

kubectl -n apps get deploy web -o jsonpath='{.spec.template.spec.containers[0].image}'
# nginx:1.25

kubectl -n apps get deploy web -o jsonpath='{.spec.strategy.rollingUpdate}'
# {"maxSurge":1,"maxUnavailable":0}

kubectl -n apps rollout history deploy/web     # CHANGE-CAUSE에 bump to 1.26 이 남아 있음
kubectl -n apps get rs                          # 현재 리비전만 DESIRED 4, 나머지 0
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `kubectl set image deploy/X <컨테이너이름>=<이미지>` — 가운데는 **컨테이너 이름**이고 Deployment 이름과 같지 않다.
- **헷갈리는 지점**: `rollout pause` 는 롤아웃만 멈춥니다. 파드를 멈추거나 트래픽을 끊지 않습니다. 그리고 `rollout undo`(직전 리비전)와 `rollout undo --to-revision=N`(지정 리비전)을 섞어 쓰면 엉뚱한 버전으로 갑니다. `rollout history --revision=N` 으로 먼저 내용을 확인하는 습관이 안전합니다.

## 참고 문서

- 검색어: `rolling back a deployment`
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
