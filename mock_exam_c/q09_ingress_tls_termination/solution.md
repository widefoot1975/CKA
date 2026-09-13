# q09 — Terminate TLS at an Ingress · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

인그레스 컨트롤러가 설치되어 있고 IngressClass 이름은 `nginx` 다. 네임스페이스 `secure` 에
Deployment `portal` (3 레플리카, `nginx:1.27`, 포트 80)이 있다.

1. `portal` 을 포트 80의 ClusterIP Service `portal` 로 노출한다.
2. CN이 `portal.example.com` 인 자체 서명 인증서와 키를 365일 유효하게 생성하고
   `/opt/course/q09/tls.crt`, `/opt/course/q09/tls.key` 에 저장한다.
3. 그 두 파일로 네임스페이스 `secure` 에 TLS 타입 Secret `portal-tls` 를 만든다.
4. `secure` 에 IngressClass `nginx` 를 쓰는 Ingress `portal-ing` 를 만든다. 호스트
   `portal.example.com` 에 대해 그 Secret으로 TLS를 종료하고, 경로 `/` (prefix)를
   `portal` Service 포트 80으로 라우팅한다.
5. 그 호스트로 HTTPS 요청 시 페이지가 서비스되고 제시된 인증서의 subject가
   `portal.example.com` 인지 확인한다.
6. 컨트롤러가 Secret의 어떤 필드를 읽는지, Secret이 Ingress와 같은 네임스페이스에 있어야 하는
   이유를 적는다.

## 모범 풀이

```bash
kubectl -n secure expose deploy portal --name=portal --port=80 --target-port=80

mkdir -p /opt/course/q09
openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
  -keyout /opt/course/q09/tls.key \
  -out /opt/course/q09/tls.crt \
  -subj "/CN=portal.example.com" \
  -addext "subjectAltName=DNS:portal.example.com"

kubectl -n secure create secret tls portal-tls \
  --cert=/opt/course/q09/tls.crt \
  --key=/opt/course/q09/tls.key
```

`-nodes` 를 빼면 키에 패스프레이즈를 물어보고, 비대화로 돌리면 실패합니다. `-addext` 의 SAN이
없으면 `curl` 이 "no alternative certificate subject name matches" 로 거부합니다 — 최신 클라이언트는
CN만으로는 호스트 검증을 하지 않습니다.

```yaml
# portal-ing.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: portal-ing
  namespace: secure
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - portal.example.com
      secretName: portal-tls
  rules:
    - host: portal.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: portal
                port:
                  number: 80
```

```bash
kubectl apply -f portal-ing.yaml
```

**6) Secret 필드와 네임스페이스 제약**: `kubectl create secret tls` 는 `kubernetes.io/tls`
타입 Secret을 만들고 데이터 키를 **`tls.crt` 와 `tls.key`** 로 고정합니다. 컨트롤러는 이 두 키를
이름으로 찾습니다. `--from-file` 로 generic Secret을 만들어 키 이름이 `cert.pem` 이 되면
컨트롤러가 인증서를 찾지 못하고 기본 자체 서명 인증서(fake certificate)를 내보냅니다 —
curl이 "Kubernetes Ingress Controller Fake Certificate" 를 보여 주면 이 상황입니다.

`spec.tls[].secretName` 에는 네임스페이스를 쓸 수 없습니다. Ingress 오브젝트와 같은
네임스페이스에서만 조회되며, 이는 네임스페이스 경계를 넘어 다른 팀의 개인키를 읽지 못하게 하는
의도적 제약입니다. 인증서를 여러 네임스페이스에서 쓰려면 Secret을 각 네임스페이스에 복제해야 합니다.

## 검증

```bash
kubectl -n secure get ingress portal-ing
# CLASS=nginx, HOSTS=portal.example.com, PORTS=80, 443  (443이 보이면 tls 블록이 인식된 것)

kubectl -n secure get secret portal-tls
# TYPE kubernetes.io/tls   DATA 2
kubectl -n secure get secret portal-tls -o jsonpath='{.data}' | tr ',' '\n'
# "tls.crt":..., "tls.key":...

IP=$(kubectl -n secure get ingress portal-ing -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl -sk --resolve portal.example.com:443:$IP https://portal.example.com/ | head -3
# nginx 기본 페이지

curl -vk --resolve portal.example.com:443:$IP https://portal.example.com/ 2>&1 | grep subject
# subject: CN=portal.example.com

kubectl -n secure get ep portal        # 파드 IP 3개
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: TLS Secret의 데이터 키는 반드시 `tls.crt` / `tls.key`. `create secret tls` 를 쓰면 자동이다.
- **헷갈리는 지점**: `spec.tls[].hosts` 의 값과 `spec.rules[].host` 의 값은 각각 다른 일을 합니다.
  `tls.hosts` 는 SNI로 어떤 인증서를 고를지, `rules.host` 는 어떤 백엔드로 보낼지 결정합니다.
  둘 중 하나만 쓰면 TLS는 되는데 404가 나거나(rules 누락), 라우팅은 되는데 fake 인증서가
  나옵니다(tls 누락). 항상 짝으로 씁니다.

## 참고 문서

- 검색어: `ingress tls`
- https://kubernetes.io/docs/concepts/services-networking/ingress/#tls
- https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
