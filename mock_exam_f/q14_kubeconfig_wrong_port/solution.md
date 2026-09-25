# q14 — kubectl cannot reach the API server · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`k8s-c1` 에서 모든 `kubectl` 명령이 실패한다. 예를 들어 `kubectl get nodes` 가
`The connection to the server cp01:6444 was refused - did you specify the right host or port?` 를 낸다.
API server 자체는 `cp01` 의 포트 `6443` 에서 정상 동작 중이다. `k8s-c1` 의 `kubectl` 은 kubeconfig 파일
`~/.kube/config` 를 쓴다.

1. `kubectl` 을 쓰지 않고 API server 가 `https://cp01:6443/livez` 에 응답한다는 것을 보인다.
2. 지금 `~/.kube/config` 에 설정된 잘못된 서버 URL 을 `/opt/course/f14/cause.txt` 에 쓴다.
3. `kubectl get nodes` 가 다시 동작하도록 `~/.kube/config` 를 고친다.

## 모범 풀이

**1) 서버는 정상인가 — curl 로 직접**

```bash
curl -k https://cp01:6443/livez            # ok
curl -k https://cp01:6444/livez            # curl: (7) Failed to connect to cp01 port 6444 ...  (연결 거부)
```

`/livez` 는 인증 없이 읽을 수 있는 헬스 체크 엔드포인트입니다. `-k` 는 클러스터 CA 가 시스템 신뢰 목록에
없어서 인증서 검증을 건너뛰는 것입니다(`--cacert` 로 CA 파일을 줘도 됩니다). 6443 은 `ok`, 6444 는 연결
거부 — 서버가 아니라 kubectl 이 가는 주소가 틀렸습니다.

**2) 잘못된 값 기록 → 3) 수정**

```bash
echo $KUBECONFIG                            # 비어 있으면 ~/.kube/config 를 쓴다
mkdir -p /opt/course/f14
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}{"\n"}' > /opt/course/f14/cause.txt
cat /opt/course/f14/cause.txt               # https://cp01:6444

kubectl config get-clusters                 # NAME: kubernetes (kubeadm 기본 이름)
kubectl config set-cluster kubernetes --server=https://cp01:6443
```

`kubectl config` 하위 명령은 kubeconfig 파일만 읽고 고치므로 API server 에 닿지 않아도 동작합니다.
`vi ~/.kube/config` 로 `server:` 줄을 직접 고쳐도 됩니다.

**핵심 — 오류 문장이 어느 단계에서 실패했는지 알려 줍니다.**

| 오류 | 실패한 단계 | 흔한 원인 |
|---|---|---|
| `connection refused` | TCP 연결 — 호스트는 닿았지만 그 포트에 듣는 프로세스가 없음 | 잘못된 포트, API server 다운 |
| `i/o timeout` / `no such host` | TCP 연결 / 이름 해석 | 잘못된 호스트·IP, 방화벽, DNS |
| `x509: certificate signed by unknown authority` | TLS | kubeconfig 의 CA 가 클러스터 CA 와 다름 |
| `Unauthorized` (401) | 인증 | 클라이언트 인증서·토큰 만료 또는 잘못됨 |
| `Forbidden` (403) | 인가 | RBAC 권한 없음 |

## 검증

```bash
kubectl get nodes                           # 노드 목록이 정상 출력
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}{"\n"}'   # https://cp01:6443
cat /opt/course/f14/cause.txt               # https://cp01:6444
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `connection refused` 는 네트워크 주소 문제다. 서버를 `curl -k https://<host>:6443/livez` 로 직접 확인하고, kubeconfig 의 `server:` 를 `kubectl config set-cluster <이름> --server=...` 로 고친다.
- **헷갈리는 지점**: `x509` 나 `Unauthorized` 가 나왔다면 연결 자체는 성공한 것이므로 주소가 아니라 CA 나 자격 증명을 봐야 합니다. 그리고 `KUBECONFIG` 환경 변수가 설정되어 있으면 `~/.kube/config` 대신 그 파일이 쓰이므로, 고친 파일이 실제로 쓰이는 파일인지 먼저 확인합니다.

## 참고 문서

- 검색어: `organize cluster access kubeconfig`, `api server health`
- https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/
- https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
- https://kubernetes.io/docs/reference/using-api/health-checks/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
