# 시험장 치트시트

외울 것이 아니라, **모의시험 볼 때마다 실제로 쓴 것만** 남겨서 줄여 나가는 문서입니다.

## 0. 호스트에 들어갈 때마다

2025년 개편 이후에는 문제마다 다른 호스트로 `ssh` 합니다. 응시 후기에 따르면 `k` alias와 자동완성은
호스트마다 미리 설정되어 있고, 직접 만든 alias·`.vimrc` 는 다음 호스트에서 사라집니다. 설정에 시간을
쓰지 말고, 꼭 필요하면 들어갈 때마다 한 줄만 붙입니다.

```bash
export do='--dry-run=client -o yaml' now='--force --grace-period=0'   # k run x --image=nginx $do
```

> yaml 붙여넣기가 밀려서 깨지면 vim에서 `:set paste` 후 붙이고 `:set nopaste`.

## 1. 문제마다 반드시

```bash
ssh <문제가 지정한 호스트>     # 지정 호스트가 아닌 곳에서 작업하면 0점
sudo -i                       # 노드 파일·systemctl 작업이 필요할 때
# ... 풀이 ...
exit                          # 베이스 터미널로 돌아온 뒤 다음 문제로
```

## 2. 매니페스트를 빨리 만드는 법

`$do` 는 **`--` 앞에** 둡니다. `--` 뒤에 쓰면 컨테이너 명령의 인자가 되어 오브젝트가 실제로 만들어집니다.

```bash
k run nginx --image=nginx $do > pod.yaml
k create deploy web --image=nginx --replicas=3 $do > deploy.yaml
k create job pi --image=perl $do -- perl -e 'print 1' > job.yaml
k create cj hello --image=busybox --schedule='*/1 * * * *' $do -- date > cj.yaml
k create job manual-1 --from=cronjob/hello                   # CronJob 을 지금 한 번 실행
k create svc clusterip web --tcp=80:80 $do > svc.yaml        # 셀렉터가 app=web 으로 만들어진다
k create svc clusterip db --clusterip=None --tcp=5432:5432   # headless
k expose deploy web --port=80 --target-port=8080 --name=web-svc $do > svc.yaml
k expose deploy web --name=web-headless --port=80 --cluster-ip=None   # expose 는 deploy/rs/rc/pod/svc 만 (sts 불가)
k set selector svc web-svc app=web                           # 서비스 셀렉터 교체
k create cm app --from-literal=k=v $do > cm.yaml
k create secret generic s1 --from-literal=pw=1234 $do > secret.yaml
k create secret tls t1 --cert=tls.crt --key=tls.key         # 키 이름이 tls.crt / tls.key 로 고정
k create sa builder $do > sa.yaml
k create role r1 --verb=get,list --resource=pods $do > role.yaml     # 모든 리소스에 같은 동사
k create rolebinding rb1 --role=r1 --serviceaccount=default:builder $do > rb.yaml
k create ingress web --rule='host/path*=svc:80' $do > ing.yaml      # 끝에 * = Prefix, 없으면 Exact
k create pdb web-pdb --selector=app=web --min-available=2
k set resources deploy web --requests=cpu=100m --limits=cpu=200m    # kubectl run 에는 --limits 없음
```

필드 이름이 기억나지 않을 때 문서보다 빠른 방법 (CRD도 된다):

```bash
k explain pod.spec.containers.resources --recursive
k explain certificates.spec.dnsNames            # 구조적 스키마가 있는 CRD
```

## 3. Troubleshooting (30% — 가장 큰 배점)

```bash
# 클러스터 전체 상태
k get nodes -o wide
k get pods -A -o wide --field-selector=status.phase!=Running
k get events -A --sort-by=.lastTimestamp | tail -30

# 파드
k describe pod <p>                  # Events 섹션이 답을 알려줌
k logs <p> -c <container> --previous   # -c 를 빼면 에러 없이 "첫 컨테이너"가 선택된다
k logs -l app=x --tail=-1 --prefix     # -l 을 쓰면 기본 --tail 이 파드당 10줄
k exec -it <p> -- sh

# 서비스 — Endpoints 는 v1.33 부터 deprecated
k get endpointslice -l kubernetes.io/service-name=<svc>

# 노드가 NotReady일 때 (노드에 ssh 후)
systemctl status kubelet
journalctl -u kubelet -n 50 --no-pager
systemctl cat kubelet               # 드롭인(10-kubeadm.conf) 실제 경로
systemctl status containerd
k debug node/<node> -it --image=busybox:1.36   # ssh 없이 노드 파일시스템(/host) 보기

# 컨트롤 플레인이 죽었을 때 — 정적 파드 매니페스트 확인
ls -la /etc/kubernetes/manifests/   # 점(.)으로 시작하지 않는 모든 파일을 kubelet 이 읽는다
crictl ps -a                        # 컨테이너는 -a 필요
crictl pods --state notready        # pods 는 기본이 전부 (-a 없음)
crictl logs <container-id>          # 직전 시도는 crictl logs -p <id>

# 인증 관련
ls /etc/kubernetes/           # admin.conf, kubelet.conf
k get --raw /api/v1/nodes/<node>/proxy/configz   # kubelet 이 실제로 쓰는 설정(기본값 포함)
```

**자주 나오는 원인**: `/etc/kubernetes/manifests/` yaml 오타, kubelet 설정 파일 경로 오류, 잘못된 `containerRuntimeEndpoint`, 서비스가 파드를 못 잡는 label selector 불일치.

## 4. 노드 관리

```bash
k drain <node> --ignore-daemonsets --delete-emptydir-data
k cordon <node>
k uncordon <node>
k taint node <node> key=value:NoSchedule
k taint node <node> key-                 # 제거
# "스케줄되는지" 확인은 nodeName 이 아니라 nodeSelector 로 (nodeName 은 스케줄러를 건너뛴다)
k run t --image=nginx --overrides='{"spec":{"nodeSelector":{"kubernetes.io/hostname":"<node>"}}}'
```

## 5. kubeadm 업그레이드 순서

```bash
# (1) 새 마이너 버전 repo로 먼저 바꿔야 함 — 노드마다! 이걸 빼면 패키지가 안 보임
vi /etc/apt/sources.list.d/kubernetes.list   # .../core:/stable:/v1.NN/deb/
apt update

# (2) 첫 컨트롤 플레인
apt-mark unhold kubeadm && apt install -y kubeadm=1.NN.X-* && apt-mark hold kubeadm
kubeadm upgrade plan
kubeadm upgrade apply v1.NN.X

k drain <cp-node> --ignore-daemonsets
apt-mark unhold kubelet kubectl && apt install -y kubelet=1.NN.X-* kubectl=1.NN.X-* && apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet
k uncordon <cp-node>

# (3) 나머지 컨트롤 플레인·워커: 저장소 변경 → kubeadm 설치 → apply 대신 node → drain → kubelet → uncordon
kubeadm upgrade node

# HA 컨트롤 플레인 join 명령 (certificate key 는 2시간, token 은 24시간)
kubeadm token create --print-join-command --certificate-key $(kubeadm init phase upload-certs --upload-certs | tail -1)
```

## 6. etcd 백업 / 복구

```bash
# 백업 (etcd 3.4 부터 ETCDCTL_API=3 은 기본값)
etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /opt/backup.db

# 확인
etcdutl --write-out=table snapshot status /opt/backup.db

# 복구 — etcd 3.6 부터 etcdctl snapshot restore 는 제거됨, etcdutl 필수
etcdutl snapshot restore /opt/backup.db --data-dir=/var/lib/etcd-restore
# 그 다음 /etc/kubernetes/manifests/etcd.yaml 의 hostPath 를 새 data-dir 로 수정
# → 정적 파드가 자동 재시작될 때까지 대기
```

인증서 경로는 `/etc/kubernetes/manifests/etcd.yaml`에서 확인하는 게 확실합니다. 멤버 확인은
`etcdctl member list -w table`, `etcdctl endpoint health --cluster -w table`.

## 7. Helm

```bash
helm repo add <name> <url> && helm repo update
helm search repo <name>/<chart> --versions | head       # 버전은 --version 으로 고정
helm show values <name>/<chart> --version <v> > values.yaml   # 설치 전 기본값
helm install <rel> <name>/<chart> --version <v> -n <ns> --create-namespace --set a=b
helm upgrade <rel> <name>/<chart> --version <v> -n <ns> --reuse-values --set a=c   # 빼면 이전 --set 이 사라짐
helm get values <rel> -n <ns>                           # 이 릴리스에 실제로 적용된 값
helm history <rel> -n <ns>; helm rollback <rel> <rev> -n <ns>
helm template <rel> <name>/<chart> --version <v> -n <ns> > out.yaml   # 설치 없이 렌더링
```

## 8. Kustomize

```bash
k kustomize <dir>            # 렌더만
k apply -k <dir>             # 적용 (-f 가 아니다)
```

오버레이 `kustomization.yaml` 에서 `resources`(base 참조), `namespace`, `namePrefix`, `labels`(구 `commonLabels` 대신,
`includeSelectors: false` 기본), `replicas`, `images`, `configMapGenerator`, `patches`(`target` 지정)를 씁니다.
`replicas`/`patches` 의 이름은 접두사가 붙기 **전** 원래 이름입니다.

## 9. Gateway API

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: gw, namespace: app}
spec:
  gatewayClassName: nginx
  listeners:
  - name: https
    protocol: HTTPS
    port: 443
    hostname: app.example.com
    tls: {mode: Terminate, certificateRefs: [{kind: Secret, name: app-tls}]}
    allowedRoutes: {namespaces: {from: Same}}     # 기본값 Same
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: route, namespace: app}
spec:
  parentRefs: [{name: gw, sectionName: https}]    # sectionName = listener 이름
  hostnames: [app.example.com]
  rules:
  - matches: [{path: {type: PathPrefix, value: /}}]
    backendRefs: [{name: web, port: 80, weight: 90}, {name: web-v2, port: 80, weight: 10}]
```

```bash
k get crd gateways.gateway.networking.k8s.io -o jsonpath='{.metadata.annotations}'   # bundle-version, channel
k get gateway -A; k get httproute -A
k get httproute <r> -o jsonpath='{range .status.parents[0].conditions[*]}{.type}={.status} ({.reason}){"\n"}{end}'
```

404 = 매칭되는 route 없음(호스트·경로), 500 = backendRef 무효(`ResolvedRefs=False`), 503 = backend의 ready endpoint 없음.
다른 네임스페이스의 Secret·Service 참조는 참조를 **받는** 쪽에 `ReferenceGrant`.

## 10. 워크로드·스케줄링

```bash
# HPA — behavior 는 명령형 플래그가 없으므로 뽑아서 추가
k autoscale deploy web --cpu=60% --min=2 --max=8 $do > hpa.yaml   # 옛 kubectl 은 --cpu-percent=60
#   spec.behavior.scaleDown.stabilizationWindowSeconds: 30

# 실행 중인 파드의 CPU·메모리 변경 (1.35 GA, QoS 클래스는 못 바꾼다)
k patch pod <p> --subresource resize -p '{"spec":{"containers":[{"name":"c","resources":{"limits":{"memory":"256Mi"}}}]}}'

# PriorityClass — system-* 제외 최댓값
k get pc -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.value}{"\n"}{end}' | grep -v '^system-' | sort -k2 -n | tail -1

# RBAC 확인 — 서브리소스는 --subresource (deployments/scale 로 쓰면 이름으로 해석됨)
k auth can-i update deployments --subresource=scale -n <ns> --as=system:serviceaccount:<ns>:<sa>
```

## 11. 자주 쓰는 조회

```bash
k get po -A --sort-by=.metadata.creationTimestamp
k get po -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.podIP}{"\n"}{end}'
k top node; k top pod -A --containers
k get po -l app=web --show-labels
k api-resources --api-group=<group>
```

## 12. 시간 관리

- 배점이 큰 문제부터. 화면에 배점이 표시됩니다.
- 3분 안에 진입점이 안 보이면 **flag 걸고 넘어갑니다.**
- 마지막 10분은 새 문제를 풀지 않고 검증에만 씁니다.
