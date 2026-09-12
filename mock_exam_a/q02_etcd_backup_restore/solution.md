# q02 — Back up and restore etcd from a snapshot · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

컨트롤 플레인 노드는 stacked etcd로 구성되어 있다. 다음을 수행한다.

1. etcd 스냅샷을 `/opt/etcd-backup.db` 에 저장한다.
2. 스냅샷을 찍은 **뒤에** 임의의 ConfigMap을 하나 만든다. 복구가 실제로 반영됐는지 나중에 판별하기 위한 표식이다.
3. 그 스냅샷을 `/var/lib/etcd-restore` 로 복구하고, etcd 정적 파드가 그 디렉터리를 사용하도록 만든다.
4. 클러스터가 다시 정상인지, 그리고 2번에서 만든 ConfigMap이 사라졌는지 확인한다.

인증서 경로를 외워서 쓰지 말고 매니페스트에서 찾아낸다.

## 모범 풀이

**인증서·데이터 경로 확인**

```bash
grep -E 'cert-file|key-file|trusted-ca-file|listen-client-urls|--data-dir' \
  /etc/kubernetes/manifests/etcd.yaml
```

**백업** — etcd 서버와 통신하므로 인증서 3개가 필요합니다.

```bash
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /opt/etcd-backup.db
```

**복구 확인용 마커**

```bash
kubectl create configmap after-backup --from-literal=k=v
```

**복구** — etcd 3.5+ 에서는 `etcdctl snapshot restore`가 deprecated이고 `etcdutl`이 권장됩니다. 복구는 서버와 통신하지 않으므로 인증서 옵션이 필요 없습니다.

```bash
etcdutl snapshot restore /opt/etcd-backup.db --data-dir=/var/lib/etcd-restore
```

**정적 파드가 새 디렉터리를 쓰게 변경**

```bash
vi /etc/kubernetes/manifests/etcd.yaml
# volumes: 의 etcd-data hostPath.path 를
#   /var/lib/etcd  →  /var/lib/etcd-restore
```

저장하면 kubelet이 매니페스트 변경을 감지해 etcd 파드를 재생성합니다. 1~2분 걸립니다.

## 검증

```bash
etcdutl --write-out=table snapshot status /opt/etcd-backup.db
crictl ps | grep etcd
kubectl get nodes
kubectl get cm after-backup          # NotFound 여야 복구 성공
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 인증서 3개는 **백업에만** 필요, 복구에는 불필요.
- **헷갈리는 지점**: 복구만 하고 `hostPath`를 안 바꾸면 예전 데이터로 그냥 뜬다 — 복구한 것처럼 보이지만 아님. 여기서 점수가 날아갑니다.

## 참고 문서

- 검색어: `etcd backup`
- https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
