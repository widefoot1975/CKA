# q08 — Service를 NodePort로 노출

| 항목 | 내용 |
|---|---|
| 회차 | mock_exam_a |
| 도메인 | Services & Networking (20%) |
| 배점 | 7 |
| 컨텍스트 | `kubectl config use-context k8s-c1` |
| 목표 시간 | 7분 |
| 결과 | ☐ 정답 ☐ 부분 ☐ 오답 |

## 문제

1. `shop` 네임스페이스에 Deployment `catalog` 를 만든다. 이미지 `nginx`, replicas 3, 컨테이너 포트 80.
2. 이 Deployment를 `catalog-svc` 라는 **NodePort** Service로 노출한다.
   - Service 포트는 `8080`, 타깃 포트는 `80`, 노드 포트는 `30080` 으로 고정한다.
3. Service의 Endpoints에 파드 IP 3개가 잡히는지 확인한다.
4. 클러스터 내부에서 Service 이름으로, 그리고 노드 IP:30080 으로 각각 접근해 응답을 확인한다.

## 내 풀이

```bash

```

<details>
<summary><b>모범 풀이</b> — 직접 풀고 나서 펼치세요</summary>

```bash
kubectl create namespace shop
kubectl -n shop create deploy catalog --image=nginx --replicas=3
```

`nodePort` 를 특정 값으로 고정해야 하므로 yaml로 만드는 편이 확실합니다.

```bash
kubectl -n shop expose deploy catalog \
  --name=catalog-svc --type=NodePort --port=8080 --target-port=80 \
  --dry-run=client -o yaml > svc.yaml

vi svc.yaml     # ports[0] 에 nodePort: 30080 추가
kubectl apply -f svc.yaml
```

결과:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: catalog-svc
  namespace: shop
spec:
  type: NodePort
  selector:
    app: catalog          # expose 가 Deployment 의 label 에서 자동 생성
  ports:
  - port: 8080            # Service 포트 (ClusterIP:8080)
    targetPort: 80        # 컨테이너 포트
    nodePort: 30080       # 노드 포트
    protocol: TCP
```

세 포트의 의미를 구분하세요. `port` 는 Service, `targetPort` 는 파드 안 컨테이너, `nodePort` 는 노드 외부.

</details>

## 검증

```bash
kubectl -n shop get svc catalog-svc
kubectl -n shop get endpoints catalog-svc      # ENDPOINTS 에 IP 3개
kubectl -n shop describe svc catalog-svc | grep -E 'Port|Endpoints|Selector'

# 클러스터 내부에서
kubectl -n shop run tmp --rm -it --image=busybox:1.36 --restart=Never -- \
  wget -qO- catalog-svc:8080 | head -5

# 노드에서
curl -s <node-ip>:30080 | head -5
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `nodePort` 기본 범위는 30000–32767. 그 밖의 값은 거부됩니다.
- **헷갈리는 지점**: `--port` 는 Service 포트고 `--target-port` 가 컨테이너 포트입니다. 반대로 넣으면 Service는 만들어지는데 응답이 없어 원인 찾기가 어렵습니다.

## 참고 문서

- 검색어: `service nodeport`
- https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
