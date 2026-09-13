# q10 — Headless Service and StatefulSet pod DNS · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `data` 에 파드별 고정 주소 체계를 만든다.

1. `app=db` 를 선택하는 헤드리스 Service `db` 를 만든다. 포트 5432, 이름 `pg`.
2. `nginx:1.27` (실제 DB 대역) 3 레플리카의 StatefulSet `db` 를 만든다. 레이블 `app=db`,
   컨테이너 포트 5432, `db` Service가 관리한다.
3. 같은 네임스페이스의 임시 파드에서 다음을 조회한다:
   - Service 이름 `db`
   - 개별 파드 `db-0`
   각각 무엇을 반환하고 어떻게 다른지 기록한다.
4. `db-2` 의 FQDN을 `/opt/course/q10/fqdn.txt` 에 쓴다.
5. 같은 셀렉터와 포트로 일반 ClusterIP Service `db-rw` 를 하나 더 만들고, DNS 응답이 헤드리스와
   어떻게 다른지 보인다.
6. `db-0` 은 이름으로 조회되는데 Deployment의 파드는 안 되는 이유를 설명한다.

## 모범 풀이

```yaml
# q10.yaml
apiVersion: v1
kind: Service
metadata:
  name: db
  namespace: data
spec:
  clusterIP: None              # 이것이 헤드리스로 만드는 유일한 조건
  selector:
    app: db
  ports:
    - name: pg
      port: 5432
      targetPort: 5432
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: db
  namespace: data
spec:
  serviceName: db              # 헤드리스 서비스 이름. DNS 서브도메인이 여기서 나온다
  replicas: 3
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
        - name: db
          image: nginx:1.27
          ports:
            - name: pg
              containerPort: 5432
```

```bash
kubectl apply -f q10.yaml
kubectl -n data expose sts db --name=db-rw --port=5432 --target-port=5432
```

**3) 조회**

```bash
kubectl -n data run t --rm -it --image=busybox:1.36 --restart=Never -- sh
nslookup db
#   Name: db.data.svc.cluster.local
#   Address: 10.244.1.7
#   Address: 10.244.2.5
#   Address: 10.244.1.9      ← 파드 IP 3개가 그대로 나온다

nslookup db-0.db.data.svc.cluster.local
#   Address: 10.244.1.7      ← 그 파드 IP 하나만

nslookup db-rw
#   Address: 10.96.211.4     ← ClusterIP 가상 IP 하나
```

헤드리스 서비스는 ClusterIP를 할당받지 않으므로 DNS가 가상 IP 대신 **Ready 상태인 백엔드 파드
IP 전부**를 A 레코드로 돌려줍니다. 일반 ClusterIP 서비스는 안정적인 가상 IP 하나만 돌려주고
그 뒤의 파드 선택은 kube-proxy가 합니다. 클라이언트가 어떤 인스턴스에 붙을지 스스로 결정해야
하는 데이터베이스 복제 구성에서 헤드리스가 필요한 이유입니다.

**4) FQDN**

```bash
mkdir -p /opt/course/q10
echo "db-2.db.data.svc.cluster.local" > /opt/course/q10/fqdn.txt
```

형식은 `<파드이름>.<서비스이름>.<네임스페이스>.svc.cluster.local` 입니다. 서비스 이름 자리에
`serviceName` 값이 들어간다는 점이 핵심 — StatefulSet 이름이 아니라 `spec.serviceName` 입니다.
이 문제에서는 둘 다 `db` 라 구분이 안 되지만, 다르게 지정된 경우 여기서 틀립니다.

**6) 왜 Deployment 파드는 안 되는가**: 파드별 A 레코드는 StatefulSet이 만들어 주는 것이 아니라
**헤드리스 서비스 + 파드의 안정적 `hostname`/`subdomain`** 조합에서 나옵니다. StatefulSet은 각
파드에 결정론적 이름(`db-0`)과 `spec.hostname`, `spec.subdomain` 을 자동으로 세팅합니다.
Deployment의 파드는 이름이 `web-7d9f-xk2mq` 처럼 매번 바뀌고 hostname/subdomain이 설정되지
않으므로 조회할 안정적인 이름 자체가 존재하지 않습니다.

## 검증

```bash
kubectl -n data get svc
# db      ClusterIP   None          <none>   5432/TCP
# db-rw   ClusterIP   10.96.211.4   <none>   5432/TCP

kubectl -n data get pods -l app=db -o wide     # db-0, db-1, db-2

kubectl -n data run v --rm -it --image=busybox:1.36 --restart=Never -- \
  nslookup db-2.db.data.svc.cluster.local      # db-2 의 IP 하나

kubectl -n data run v2 --rm -it --image=busybox:1.36 --restart=Never -- \
  nslookup db | grep -c Address                # 파드 수 + 1 (서버 줄 포함)

cat /opt/course/q10/fqdn.txt
kubectl -n data get ep db                      # 파드 IP 3개 (헤드리스도 엔드포인트는 만든다)
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 파드 DNS는 `<pod>.<serviceName>.<ns>.svc.cluster.local`. StatefulSet 이름이 아니라 `spec.serviceName` 이다.
- **헷갈리는 지점**: `kubectl expose` 로는 헤드리스 서비스를 만들 수 없습니다 — `--cluster-ip=None`
  플래그가 있지만 yaml로 `clusterIP: None` 을 쓰는 편이 확실합니다. 그리고 `serviceName` 에
  존재하지 않는 서비스를 적어도 StatefulSet은 정상적으로 생성되고 파드도 뜹니다. DNS만 조용히
  안 되므로 오브젝트 상태만 보면 발견되지 않습니다.

## 참고 문서

- 검색어: `dns for services and pods`
- https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
- https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#stable-network-id

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
