# q02 — etcd 스냅샷 백업 후 복구

| 항목 | 내용 |
|---|---|
| 회차 | mock_exam_a |
| 도메인 | Cluster Architecture, Installation & Configuration (25%) |
| 배점 | 8 |
| 컨텍스트 | 컨트롤 플레인 노드에 ssh 접속 후 root |
| 목표 시간 | 12분 |
| 결과 | ☐ 정답 ☐ 부분 ☐ 오답 |

## 문제

컨트롤 플레인 노드의 stacked etcd를 대상으로 다음을 수행한다.

1. etcd 스냅샷을 `/opt/etcd-backup.db` 에 저장한다.
2. 스냅샷을 찍은 뒤 임의의 ConfigMap을 하나 만들어 둔다 (복구 확인용).
3. 저장한 스냅샷을 `/var/lib/etcd-restore` 로 복구하고, etcd 정적 파드가 그 디렉터리를 쓰도록 바꾼다.
4. 클러스터가 정상 동작하고, **2번에서 만든 ConfigMap이 사라졌음**을 확인한다.

인증서 경로는 외우지 말고 매니페스트에서 찾아낸다.

## 내 풀이

```bash

```

<details>
<summary><b>모범 풀이</b> — 직접 풀고 나서 펼치세요</summary>

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

</details>

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
