# q03 — Manage a cluster component with Helm · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

Helm으로 `web` 네임스페이스의 컴포넌트를 설치하고 관리한다.

1. `https://charts.bitnami.com/bitnami` 를 `bitnami` 라는 이름의 차트 저장소로 추가하고 인덱스를 갱신한다.
2. **아무것도 설치하지 않은 채로** 차트의 기본값을 `/tmp/nginx-values.yaml` 에 저장한다.
3. `bitnami/nginx` 를 릴리스 `frontend` 로 `web` 네임스페이스에 설치한다. 네임스페이스를 함께 만들고 `replicaCount` 는 `2` 로 한다.
4. **이미 지정한 값을 잃지 않으면서** `replicaCount=4` 로 업그레이드한다.
5. 릴리스 히스토리를 보고, 리비전 1로 롤백한 뒤 replica 수가 다시 2인지 확인한다.

## 모범 풀이

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo bitnami/nginx
```

**2) 설치 없이 값만 보기**

```bash
helm show values bitnami/nginx > /tmp/nginx-values.yaml
```

**3) 설치**

```bash
helm install frontend bitnami/nginx \
  --namespace web --create-namespace \
  --set replicaCount=2
```

**4) 업그레이드** — `--reuse-values` 가 이 문제의 핵심입니다.

```bash
helm upgrade frontend bitnami/nginx \
  --namespace web --reuse-values \
  --set replicaCount=4
```

`--reuse-values` 없이 `--set` 만 쓰면 **이전에 지정한 값들이 차트 기본값으로 되돌아갑니다.** 값이 하나뿐이면 티가 안 나지만, 여러 개를 설정한 릴리스에서는 설정이 조용히 날아갑니다. 값 파일로 관리한다면 `-f values.yaml` 로 매번 전체를 넘기는 편이 더 안전합니다.

**5) 히스토리와 롤백**

```bash
helm history frontend -n web
helm rollback frontend 1 -n web
```

롤백도 **새 리비전을 만듭니다.** 리비전 1로 되돌리면 히스토리에 리비전 3이 "리비전 1의 내용"으로 추가됩니다. 히스토리가 지워지지 않습니다.

## 검증

```bash
helm list -n web                     # STATUS deployed
helm history frontend -n web         # 리비전 3개
helm get values frontend -n web      # replicaCount: 2
kubectl -n web get deploy            # READY 2/2
```

설치하지 않고 결과 매니페스트만 보고 싶을 때:

```bash
helm template frontend bitnami/nginx --set replicaCount=2 | head -40
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `helm upgrade` 에 `--reuse-values` 를 빼면 이전 `--set` 값이 사라진다.
- **헷갈리는 지점**: `helm show values` 는 **차트가 제공하는 기본값**, `helm get values` 는 **이 릴리스에 실제로 적용된 값**입니다. 문제에 "설치 전"이면 `show`, "설치된 릴리스"면 `get`.

## 참고 문서

Helm은 kubernetes.io 문서에 없습니다. 시험장에서는 `helm --help` 와 `helm upgrade --help` 로 옵션을 찾는 연습을 해 두세요.

- 검색어: `helm`
- https://helm.sh/docs/helm/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
