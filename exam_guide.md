# CKA 시험 전 최종 정리 (2026 · Kubernetes v1.35)

시험 전에 **이 문서 하나만 처음부터 끝까지 읽으면** 되도록 정리했습니다. 기준은 CKA 커리큘럼 v1.35와
2026년 9월 현재의 쿠버네티스·생태계 상태입니다. 짧은 명령 모음은 [cheatsheet.md](cheatsheet.md), 연습 문제는
`mock_exam_a` ~ `mock_exam_f` 입니다(맨 끝 [연습 문제 매핑](#11-연습-문제-매핑) 참고).

## 목차

1. [시험 형식과 환경](#1-시험-형식과-환경)
2. [시간 전략과 터미널 습관](#2-시간-전략과-터미널-습관)
3. [2025~2026 트렌드 — 무엇이 바뀌었나](#3-20252026-트렌드--무엇이-바뀌었나)
4. [Cluster Architecture, Installation & Configuration (25%)](#4-cluster-architecture-installation--configuration-25)
5. [Workloads & Scheduling (15%)](#5-workloads--scheduling-15)
6. [Services & Networking (20%)](#6-services--networking-20)
7. [Storage (10%)](#7-storage-10)
8. [Troubleshooting (30%)](#8-troubleshooting-30)
9. [자주 틀리는 함정 40선](#9-자주-틀리는-함정-40선)
10. [시험 당일 체크리스트](#10-시험-당일-체크리스트)
11. [연습 문제 매핑](#11-연습-문제-매핑)

---

## 1. 시험 형식과 환경

| 항목 | 내용 |
|---|---|
| 시간 | 2시간 |
| 형식 | 실습형 — 터미널에서 실제 클러스터를 조작. 객관식 없음. 문제 수는 15~20개 안팎 |
| 합격선 | 66% |
| 기준 버전 | Kubernetes v1.35 (LF 공식 시험 페이지 기준) |
| 도메인 비중 | Troubleshooting 30 · Cluster Architecture 25 · Services & Networking 20 · Workloads & Scheduling 15 · Storage 10 |
| 열람 가능 문서 | kubernetes.io/docs, kubernetes.io/blog, **helm.sh/docs**, **gateway-api.sigs.k8s.io**(CKA만), 문제별 Quick Reference |

**2025년 개편 이후의 시험 환경** (LF 안내와 2025~2026 응시 후기 기준)

- 원격 데스크톱(PSI Secure Browser) 안의 리눅스 데스크톱에서 터미널과 브라우저를 씁니다.
- **문제마다 지정된 호스트로 `ssh`** 합니다. 문제마다 클러스터가 다르고, 그 호스트의 `kubectl` 은 이미 그 클러스터를
  가리킵니다. **지정 호스트가 아닌 곳에서 작업하면 정답이어도 0점**입니다. 문제를 마치면 `exit` 로 베이스 터미널에
  돌아온 뒤 다음 문제의 호스트로 들어갑니다.
- 노드 파일이나 `systemctl` 작업이 필요하면 그 호스트에서 다시 `ssh <node>` 하고 `sudo -i` 합니다.
- `k` alias와 자동완성은 호스트마다 미리 설정되어 있다는 후기가 많습니다. 직접 만든 alias·`.vimrc` 는 다른 호스트로
  넘어가면 사라지므로 설정에 시간을 쓰지 않습니다.
- 터미널 복사·붙여넣기는 보통 `Ctrl+Shift+C` / `Ctrl+Shift+V` 입니다.
- 문제 화면에 배점(가중치)이 표시되고, 나중에 다시 볼 문제에 표시(flag)를 해 둘 수 있습니다.

## 2. 시간 전략과 터미널 습관

### 시간 배분

- 120분 / 100점 → **1점 ≈ 1.2분**. 7점 문제에 8분 이상 쓰고 있다면 넘어갈 때입니다.
- **1회차**: 확실한 문제부터 빠르게 끝냅니다. 3분 안에 진입점이 안 보이면 flag 후 넘어갑니다.
- **2회차**: flag 문제를 봅니다. 마지막 10분은 새 문제 대신 검증에 씁니다.
- 한 문제 안에서도 할 수 있는 단계를 먼저 끝냅니다. 단계별 부분 점수가 있다고 알려져 있습니다.
- 오래 기다리는 작업(패키지 설치, 정적 파드 재시작, 롤아웃)은 걸어 두고 검증은 나중에 합니다.

### 매 문제 루틴

1. 호스트, 네임스페이스, 리소스 이름, 출력 파일 경로에 밑줄을 긋듯 읽습니다. 이름 오타는 0점입니다.
2. `ssh <host>` → 작업 → **확인**(`get`, `describe`, `cat 파일`) → `exit`.
3. 네임스페이스가 있으면 모든 명령에 `-n <ns>` 를 붙입니다. 아니면 매니페스트에 `namespace:` 를 적습니다.

### 빠르게 만드는 법

```bash
export do='--dry-run=client -o yaml'                 # 호스트마다 필요하면 한 줄
k run web --image=nginx:1.27 $do > pod.yaml           # 뼈대 → 편집 → apply
k create deploy web --image=nginx:1.27 --replicas=3 $do > deploy.yaml
k create job pi --image=busybox:1.36 $do -- sh -c 'echo hi'   # $do 는 -- 앞에
k explain pod.spec.containers.livenessProbe --recursive       # 필드 이름이 기억 안 날 때
k explain certificates.spec --recursive                        # CRD 도 된다
```

- 명령형으로 가능한 것은 명령형으로: `create`, `run`, `expose`, `set image|resources|env|selector`, `scale`,
  `rollout`, `autoscale`, `label`, `annotate`, `taint`, `cordon`, `drain`.
- 명령형으로 못 하는 것(probe, affinity, toleration, sidecar, volume, HPA behavior 등)은 dry-run yaml을 편집합니다.
- vim에서 붙여넣기가 밀리면 `:set paste` → 붙여넣기 → `:set nopaste`. yaml 들여쓰기는 스페이스 2칸, 탭 금지.
- 출력 파일 경로의 디렉터리가 없으면 `mkdir -p` 합니다. 파일에 쓴 뒤 `cat` 으로 확인합니다.

### 문서 검색어 (kubernetes.io 검색창)

| 필요한 것 | 검색어 |
|---|---|
| NetworkPolicy 예제 | `network policies` |
| Gateway·HTTPRoute | `gateway api` (상세는 gateway-api.sigs.k8s.io) |
| kubeadm 업그레이드 | `upgrading kubeadm clusters` |
| 인증서 갱신 | `certificate management with kubeadm` |
| HA 구성 | `creating highly available clusters with kubeadm` |
| etcd 백업 | `operating etcd clusters` |
| 컨테이너 런타임 준비 | `container runtimes` |
| ConfigMap/Secret 주입 | `configure a pod to use a configmap` |
| probe | `configure liveness readiness startup probes` |
| HPA | `horizontal pod autoscaling walkthrough` |
| 제자리 리소스 변경 | `resize container resources` |
| 사이드카 | `sidecar containers` |
| PV/PVC | `configure persistent volume storage`, `persistent volumes` |
| StorageClass | `storage classes` |
| 서비스 디버깅 | `debug services` |
| DNS 디버깅 | `debugging dns resolution` |
| 정적 파드 | `create static pods` |
| crictl | `debugging kubernetes nodes with crictl` |
| CSR·사용자 | `certificate signing requests` |
| Helm 옵션 | helm.sh에서 `helm upgrade` |

---

## 3. 2025~2026 트렌드 — 무엇이 바뀌었나

### 3.1 커리큘럼 개정(2025년 2월)으로 들어온 항목

예전 자료로만 공부하면 통째로 빠지는 부분입니다. 시험의 절반 가까이가 이쪽에서 나온다는 후기가 많습니다.

| 항목 | 준비할 것 |
|---|---|
| **Helm** | 저장소 추가, `--version` 고정, 설치·업그레이드(`--reuse-values`)·롤백·히스토리, `helm template`, CRD를 포함한 차트 |
| **Kustomize** | base/overlay, `namespace`·`namePrefix`·`labels`·`replicas`·`images`·`configMapGenerator`·`patches`, `kubectl apply -k` |
| **Gateway API** | Gateway·HTTPRoute, 경로·헤더 매칭, 가중치 분할, HTTPS listener, **Ingress → Gateway 이전** |
| **CRD·operator** | CRD 설치, 커스텀 리소스 생성, `kubectl api-resources`·`kubectl explain`, operator RBAC |
| **확장 인터페이스** | CRI(`crictl`, containerd·cri-dockerd), CNI(설치·선택·장애), CSI(드라이버·`volumeMode`) |
| **HA 컨트롤 플레인** | 컨트롤 플레인 join, etcd 멤버·정족수, 두 번째 이후 노드 업그레이드 |
| **워크로드 오토스케일링** | HPA `autoscaling/v2`(behavior 포함), requests 전제, metrics-server |
| **리소스 사용량 모니터링** | metrics-server, `kubectl top`, 요청·제한 대비 실사용 |
| **컨테이너 출력 스트림** | `kubectl logs` 옵션, 사이드카 로그, 노드의 로그 파일 |

커리큘럼 항목에서 **빠진 것**: etcd 백업·복구(명시 항목에서 제외 — 가볍게만 복습).

### 3.2 쿠버네티스·생태계 변화 (옛 풀이가 막히는 지점)

| 변화 | 시점 | 시험에서의 의미 |
|---|---|---|
| **Ingress NGINX 은퇴** — 이후 릴리스·보안 패치 없음 | 2026-03 | Gateway API가 후속. Ingress API 자체는 여전히 범위. 컨트롤러 전용 어노테이션에 기대지 말 것 |
| **Endpoints API deprecated** | v1.33 | `kubectl get endpoints` 는 경고. `kubectl get endpointslice -l kubernetes.io/service-name=<svc>` |
| **네이티브 사이드카 GA** (`initContainers` + `restartPolicy: Always`) | v1.33 | 사이드카 추가 과제는 이 방식 |
| **kube-proxy nftables 모드 GA** / **IPVS deprecated** | v1.33 / v1.35 | 룰 확인 명령이 모드마다 다름. nftables는 localhost NodePort 미지원 |
| **In-place Pod resize GA** | v1.35 | `kubectl patch pod --subresource resize` 로 재시작 없이 CPU·메모리 변경 |
| 환경 변수 이름 제한 완화 | v1.34 | `=` 를 뺀 출력 가능한 ASCII 거의 전부 허용 |
| 볼륨 확장 실패 복구 GA | v1.34 | 실패한 확장 요청은 `status.capacity` 보다 큰 값까지 낮출 수 있음 |
| `kubectl autoscale` 이 `--cpu=50%`, `--memory` 사용 | v1.34 레퍼런스 | `--cpu-percent` 는 deprecated |
| default StorageClass가 여럿이면 가장 최근 것 사용 | v1.26+ | 그래도 하나만 남기는 것이 원칙 |
| etcd 3.6: `etcdctl snapshot restore` 제거 | etcd 3.6 | 복구·상태 확인은 `etcdutl` |
| Helm 4 출시 | 2025-11 | 핵심 명령 동일. `--atomic` → `--rollback-on-failure` |
| Bitnami 무료 카탈로그 축소 | 2025-08~09 | 공개 Bitnami 차트는 이미지 pull 실패가 흔함 |
| Gateway API 최신 v1.6.x | 2026-09 | CRD는 `kubectl apply --server-side -f .../standard-install.yaml`, 버전은 컨트롤러 지원 버전에 맞춤 |

### 3.3 응시 후기에서 자주 언급되는 과제 유형 (2025~2026)

공개된 후기들에서 반복해서 언급되는 **유형**이며 실제 문제 원문이 아닙니다. 아래는 모두 이 문서와 연습 문제에서 다룹니다.

- Helm으로 차트 설치 — 버전 고정, CRD 설치 끄기(`crds.install=false` 류), `helm template` 로 매니페스트 생성
- 설치된 CRD 목록을 파일로 저장하고 `kubectl explain` 으로 특정 필드 문서를 파일로 저장
- **Ingress를 Gateway + HTTPRoute로 이전** (TLS 포함)
- NetworkPolicy를 지원하는 CNI를 골라 매니페스트로 설치
- cri-dockerd 패키지 설치 + 서비스 활성화 + sysctl 영구 설정
- HPA 생성(목표 사용률, min/max, **scale-down 안정화 구간**)
- 기존 사용자 정의 PriorityClass 최댓값보다 1 작은 PriorityClass 생성 후 Deployment에 적용
- 기존 Deployment에 로그 사이드카 추가(공유 볼륨 + `tail -F`)
- 노드 자원을 replica 수로 균등 분배해 requests 설정(**init 컨테이너 포함**), 0으로 줄였다가 다시 늘리기
- StorageClass 생성 + 기본값 지정 + `WaitForFirstConsumer`
- Deployment가 지워진 뒤 남은(Retain) PV를 새 PVC로 다시 연결하고 Deployment 매니페스트에 붙이기
- 여러 NetworkPolicy 후보 중 **가장 적게 여는 것** 골라 적용
- containerPort를 추가하고 NodePort Service로 노출, Ingress 생성
- taint/toleration으로 특정 노드에만 파드 배치
- 머신 이전 후 망가진 단일 노드 클러스터 복구(예: API server의 etcd 주소)
- ConfigMap 설정 변경 후 반영, immutable 설정

---

## 4. Cluster Architecture, Installation & Configuration (25%)

### 4.1 RBAC

**네 가지 조합**

| 조합 | 효과 |
|---|---|
| Role + RoleBinding | 한 네임스페이스 안에서만 |
| ClusterRole + ClusterRoleBinding | 모든 네임스페이스 + 클러스터 범위 리소스(nodes, PV 등) |
| **ClusterRole + RoleBinding** | ClusterRole의 규칙을 **그 네임스페이스에서만** 재사용 |
| Role + ClusterRoleBinding | 불가 |

```bash
k -n apps create sa monitor
k -n apps create role pod-reader --verb=get,list,watch --resource=pods,pods/log
k -n apps create rolebinding monitor-rb --role=pod-reader --serviceaccount=apps:monitor
k create clusterrole node-reader --verb=get,list,watch --resource=nodes
k create clusterrolebinding anna-nodes --clusterrole=node-reader --user=anna
k -n team-a create rolebinding anna-view --clusterrole=deployment-viewer --user=anna   # ClusterRole 재사용

k auth can-i list pods -n apps --as=system:serviceaccount:apps:monitor
k auth can-i update deployments --subresource=scale -n apps --as=...   # deployments/scale 로 쓰면 이름으로 해석된다
k auth can-i --list -n apps --as=...
```

- `apiGroups`: core `""`, `apps`(deployments·statefulsets·daemonsets·replicasets), `batch`(jobs·cronjobs),
  `networking.k8s.io`(ingresses·networkpolicies), `rbac.authorization.k8s.io`, `storage.k8s.io`,
  `gateway.networking.k8s.io`, CRD는 그 CRD의 group. 모르면 `kubectl api-resources` 의 APIVERSION 열.
- 규칙 하나는 `apiGroups × resources × verbs` 의 모든 조합입니다. `kubectl create role` 은 모든 리소스에 **같은
  동사**를 주므로, 리소스마다 동사가 다르면 yaml로 규칙을 나눕니다.
- 서브리소스(`pods/log`, `pods/exec`, `deployments/scale`)는 별도 항목입니다.
- **집계(aggregation)**: 내장 `view`/`edit`/`admin` 은 집계 ClusterRole입니다. 라벨
  `rbac.authorization.k8s.io/aggregate-to-view: "true"` 를 단 ClusterRole을 만들면 그 권한이 `view` 로 흘러갑니다.
  `view` 를 직접 편집하면 집계 컨트롤러가 덮어씁니다.

**인증서 기반 사용자 만들기**

```bash
openssl genrsa -out jane.key 2048
openssl req -new -key jane.key -out jane.csr -subj "/CN=jane/O=dev-team"    # CN=사용자, O=그룹
cat <<EOF | k apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata: {name: jane}
spec:
  request: $(base64 -w0 < jane.csr)
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400
  usages: ["client auth"]
EOF
k certificate approve jane
k get csr jane -o jsonpath='{.status.certificate}' | base64 -d > jane.crt

k config set-credentials jane --client-certificate=jane.crt --client-key=jane.key --embed-certs=true --kubeconfig=jane.kc
k config set-cluster c1 --server=https://<cp>:6443 --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true --kubeconfig=jane.kc
k config set-context jane@c1 --cluster=c1 --user=jane --kubeconfig=jane.kc
k config use-context jane@c1 --kubeconfig=jane.kc
```

인증서는 "누구인가"(인증)만 증명합니다. 권한은 RBAC(`--user=jane` 또는 `--group=dev-team`)으로 따로 줍니다.
`kubectl config` 명령에 `--kubeconfig` 를 빼면 내 `~/.kube/config` 가 바뀝니다.

### 4.2 노드 준비 (인프라)

```bash
swapoff -a && sed -i '/\sswap\s/s/^/#/' /etc/fstab       # 지금 + 재부팅 후
cat >/etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF
modprobe overlay && modprobe br_netfilter                # br_netfilter 가 있어야 net.bridge.* 키가 생긴다
cat >/etc/sysctl.d/k8s.conf <<EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# containerd — 기본 설정을 만든 뒤 systemd cgroup 드라이버
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
crictl info | grep -i systemdCgroup                      # true
apt-mark hold kubelet kubeadm kubectl
```

- containerd 2.x의 설정 경로는 `[plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc.options]`, 1.x는
  `[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]` 입니다. 경로를 외워 치지 말고 기본 설정에서 고칩니다.
  패키지가 준 `config.toml` 은 CRI 플러그인이 꺼져 있는 경우가 있습니다(`disabled_plugins = ["cri"]`).
- 공식 문서의 필수 sysctl은 `net.ipv4.ip_forward` 하나이고, bridge 관련 값은 CNI에 따라 필요합니다. 문제가 요구하면 그대로 설정합니다.
- **cri-dockerd**: `dpkg -i cri-dockerd*.deb` → `systemctl enable --now cri-docker.service cri-docker.socket` →
  엔드포인트 `unix:///var/run/cri-dockerd.sock`. `net.netfilter.nf_conntrack_max` 키가 없으면 `modprobe nf_conntrack`.

### 4.3 kubeadm — 생성·조인·업그레이드·인증서

```bash
# 생성 (그 다음 CNI 설치)
kubeadm init --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint=<LB:6443> --upload-certs

# 워커 조인 명령 — 토큰은 24시간
kubeadm token list
kubeadm token create --print-join-command
# 컨트롤 플레인 조인 — certificate key 는 2시간
kubeadm token create --print-join-command --certificate-key $(kubeadm init phase upload-certs --upload-certs | tail -1)
# CA 해시 직접 계산 (인증서 전체가 아니라 공개키 DER 의 sha256)
openssl x509 -in /etc/kubernetes/pki/ca.crt -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256
```

**업그레이드 순서** (노드마다, 한 마이너씩)

```bash
# 모든 노드에서: 저장소를 새 마이너로 — 노드마다 따로!
vi /etc/apt/sources.list.d/kubernetes.list      # .../core:/stable:/v1.35/deb/
apt update && apt-cache madison kubeadm

# 첫 컨트롤 플레인
apt-mark unhold kubeadm && apt install -y kubeadm=1.35.X-* && apt-mark hold kubeadm
kubeadm upgrade plan
kubeadm upgrade apply v1.35.X
k drain cp01 --ignore-daemonsets
apt-mark unhold kubelet kubectl && apt install -y kubelet=1.35.X-* kubectl=1.35.X-* && apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet
k uncordon cp01

# 다른 컨트롤 플레인·워커: kubeadm 설치 → kubeadm upgrade node → drain → kubelet·kubectl → restart → uncordon
```

- `apply` 는 첫 컨트롤 플레인에서 한 번(클러스터 설정·정적 파드 교체). 나머지 노드는 `upgrade node`.
- kubeadm만 올리고 kubelet을 빼먹으면 `kubectl get nodes` 의 VERSION이 그대로입니다.

**인증서**

```bash
kubeadm certs check-expiration                 # kubelet.conf 는 목록에 없다 (kubelet 이 스스로 회전)
kubeadm certs renew apiserver                  # 또는 renew all (admin.conf 도 갱신 → ~/.kube/config 로 복사)
# 정적 파드는 인증서를 다시 읽지 않는다 → 매니페스트를 잠깐 밖으로 옮겼다가 되돌려 재시작
mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/ && sleep 20 && mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate
```

### 4.4 HA 컨트롤 플레인

- stacked etcd(컨트롤 플레인 노드마다 etcd) vs external etcd. API 앞에는 `controlPlaneEndpoint`(LB/VIP) —
  `kubectl -n kube-system get cm kubeadm-config -o yaml | grep controlPlaneEndpoint`.
- **정족수 = floor(N/2)+1**

| 멤버 수 | 정족수 | 견딜 수 있는 장애 |
|---|---|---|
| 1 | 1 | 0 |
| 2 | 2 | 0 |
| 3 | 2 | 1 |
| 5 | 3 | 2 |

짝수는 정족수만 올리고 내구성은 그대로라 항상 홀수로 맞춥니다.

```bash
export ETCDCTL_ENDPOINTS=https://127.0.0.1:2379 ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \
       ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key
etcdctl member list -w table
etcdctl endpoint health --cluster -w table
etcdctl member remove <ID>          # reset 없이 재설치한 노드의 죽은 멤버는 지워야 다시 join 된다
```

**etcd 백업·복구** (커리큘럼에서 빠졌지만 가볍게)

```bash
etcdctl snapshot save /opt/backup.db                                   # 위 환경 변수 사용
etcdutl snapshot status /opt/backup.db -w table
etcdutl snapshot restore /opt/backup.db --data-dir=/var/lib/etcd-restore   # etcd 3.6부터 etcdutl 필수
# /etc/kubernetes/manifests/etcd.yaml 의 hostPath(etcd-data)를 새 디렉터리로 → 정적 파드 재생성 대기
```

### 4.5 Helm

```bash
helm repo add argo https://argoproj.github.io/argo-helm && helm repo update
helm search repo argo/argo-cd                      # CHART VERSION = 최신
helm search repo argo/argo-cd --versions | head
helm show values argo/argo-cd --version <v> > values.yaml      # 설치 전: 차트 기본값
helm install argocd argo/argo-cd --version <v> -n argocd --create-namespace --set crds.install=false
helm upgrade argocd argo/argo-cd --version <v> -n argocd --reuse-values --set server.replicas=2
helm get values argocd -n argocd                   # 설치 후: 이 릴리스에 준 값 (-a 는 전체)
helm history argocd -n argocd
helm rollback argocd 1 -n argocd                   # 롤백도 새 리비전
helm template argocd argo/argo-cd --version <v> -n argocd --set crds.install=false > argocd.yaml
helm list -A
helm uninstall argocd -n argocd
helm install x oci://registry.example.com/charts/x --version <v>   # OCI 차트
```

- 값 우선순위: 차트 기본값 < `-f` 파일(뒤에 준 것이 이김) < `--set`.
- `helm upgrade` 에 `--reuse-values` 가 없으면 **이전에 준 `--set` 값이 기본값으로 돌아갑니다.**
- **CRD 두 방식**: 차트의 `crds/` 디렉터리에 있는 CRD는 설치 때만 들어가고 업그레이드·삭제 때 건드리지 않습니다
  (`--skip-crds` 로 끔, `helm template` 에는 `--include-crds` 를 줘야 나옴). CRD를 템플릿으로 가진 차트는 값으로 제어합니다
  (argo-cd `crds.install`, cert-manager `crds.enabled`/`crds.keep`). 값을 잃어 CRD가 릴리스에서 빠지면 CRD와 **모든 커스텀
  리소스가 지워질 수 있습니다**(keep 정책이 없을 때).
- 버전은 항상 `--version` 으로 고정합니다. Helm 4에서도 위 명령은 같고 `--atomic` 만 `--rollback-on-failure` 로 바뀌었습니다.

### 4.6 Kustomize

```yaml
# overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base                      # bases 는 옛 필드
namespace: prod
namePrefix: prod-
labels:                           # commonLabels 대신 — 셀렉터를 건드리지 않음
- pairs: {env: prod}
  includeSelectors: false
replicas:
- {name: web, count: 4}           # 이름은 접두사 붙기 전 원래 이름
images:
- {name: nginx, newTag: "1.28"}   # name 은 이미지 이름
configMapGenerator:
- name: web-config
  literals: [TIER=prod]           # 이름 뒤에 내용 해시가 붙는다
patches:
- target: {kind: Deployment, name: web}
  path: port-patch.yaml           # JSON6902 또는 strategic merge
```

```bash
k kustomize overlays/prod          # 렌더만
k apply -k overlays/prod           # 적용 (-f 가 아니다)
```

### 4.7 확장 인터페이스 (CRI · CNI · CSI)

**CRI — crictl** (API server 없이 노드에서)

```bash
cat /etc/crictl.yaml               # runtime-endpoint: unix:///run/containerd/containerd.sock
crictl ps -a                       # 종료된 컨테이너까지 (-a 필요)
crictl pods                        # sandbox — 기본으로 전부 (-a 없음), --state notready
crictl logs <id>; crictl logs -p <id>     # -p = 직전 시도
crictl inspect <id> | grep -i logpath
crictl images; crictl rmi --prune; crictl info; crictl stats
k get nodes -o wide                # CONTAINER-RUNTIME 열
grep containerRuntimeEndpoint /var/lib/kubelet/config.yaml
```

**CNI**

- 설정 `/etc/cni/net.d/`(사전순 첫 파일 사용) + 바이너리 `/opt/cni/bin/`.
- 설정이 없으면 노드가 `NotReady`(`cni plugin not initialized`). 설정은 있고 바이너리가 없으면 노드는 `Ready` 인데
  파드가 `ContainerCreating`(`failed to find plugin "x" in path [/opt/cni/bin]`).
- **NetworkPolicy 적용 여부는 CNI가 정합니다.** Calico·Cilium은 적용, Flannel은 적용하지 않음(정책 오브젝트는 만들어지지만 효과 없음).
- Calico operator 설치: `kubectl create -f tigera-operator.yaml`(CRD가 커서 `apply` 는 어노테이션 크기 제한에 걸림 —
  `apply --server-side` 도 가능) → `custom-resources.yaml` 의 `ipPools[].cidr`(기본 192.168.0.0/16)를 클러스터 pod CIDR에 맞춤 →
  `kubectl create -f` → `kubectl get tigerastatus`.
- pod CIDR 찾기: `kubectl -n kube-system get cm kubeadm-config -o yaml | grep podSubnet`, 노드 `spec.podCIDR`,
  controller-manager `--cluster-cidr`.
- 증명은 "정책 전 성공 → 정책 후 실패"의 짝으로 합니다.

**CSI**

```bash
k get csidrivers                   # ATTACHREQUIRED, PODINFOONMOUNT, MODES
k get csinodes -o custom-columns=NODE:.metadata.name,DRIVERS:.spec.drivers[*].name
k get sc                           # PROVISIONER = CSI 드라이버 이름
k get volumeattachments
```

### 4.8 CRD와 operator

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: widgets.demo.example.com          # 반드시 <plural>.<group>
spec:
  group: demo.example.com
  scope: Namespaced
  names: {plural: widgets, singular: widget, kind: Widget, shortNames: [wd]}
  versions:
  - name: v1
    served: true
    storage: true                         # storage 는 버전 중 정확히 하나
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            required: [color]
            properties:
              color: {type: string}
              size: {type: integer, default: 1}
    additionalPrinterColumns:
    - {name: COLOR, type: string, jsonPath: .spec.color}
```

```bash
k get crd | grep cert-manager.io
k get crd -o custom-columns=NAME:.metadata.name --no-headers | grep cert-manager.io > crds.txt
k api-resources --api-group=cert-manager.io          # 이름, 짧은 이름, APIVERSION, NAMESPACED
k explain certificates.spec.dnsNames                  # CRD 필드 문서
k get certificates -A; k get cert -A                  # 짧은 이름
```

- 스키마에 없는 필드는 에러 없이 잘려 나갑니다(pruning). `default` 는 API server가 채웁니다.
- `kubectl get crd X` 는 정의, `kubectl get <plural>` 은 인스턴스. **CRD를 지우면 모든 인스턴스가 함께 지워집니다.**
- operator = CRD + 컨트롤러 Deployment + ServiceAccount + (Cluster)Role·Binding. 컨트롤러가
  `... is forbidden: cannot list resource "backups"` 를 내면 ClusterRole의 `apiGroups`(CRD의 group!)·동사(`list`,`watch`)와
  ClusterRoleBinding의 subject(네임스페이스·SA 이름)를 봅니다.

---

## 5. Workloads & Scheduling (15%)

### 5.1 Deployment와 롤아웃

```bash
k -n shop create deploy web --image=nginx:1.27 --replicas=4
k -n shop get deploy web -o jsonpath='{.spec.template.spec.containers[*].name}'   # 컨테이너 이름은 이미지에서 (nginx)
k -n shop set image deploy/web nginx=nginx:1.28
k -n shop annotate deploy/web kubernetes.io/change-cause="upgrade to 1.28" --overwrite   # --record 는 deprecated
k -n shop rollout status deploy/web
k -n shop rollout history deploy/web [--revision=2]
k -n shop rollout undo deploy/web [--to-revision=1]
k -n shop rollout pause|resume|restart deploy/web
k -n shop scale deploy/web --replicas=6
```

- 전략 계산: `maxSurge` 25%는 **올림**, `maxUnavailable` 25%는 **내림**. replica 3이면 surge 1, unavailable 0.
- 그래서 실패하는 readiness를 넣은 업데이트는 서비스를 끊지 않고 **롤아웃이 멈춥니다**(새 파드 1개만 unready).
- `maxSurge: 0` 과 `maxUnavailable: 0` 을 동시에 줄 수는 없습니다. `Recreate` 는 전부 내리고 다시 띄웁니다.

### 5.2 ConfigMap과 Secret

```bash
k create cm app --from-literal=MODE=prod --from-file=app.properties
k create secret generic db --from-literal='password=S3cr3t!'   # ! 는 작은따옴표로
k create secret tls web-tls --cert=tls.crt --key=tls.key       # 키 이름 tls.crt / tls.key 고정
k set env deploy/api --from=configmap/app
k rollout restart deploy/api                                    # env 는 재시작해야 반영
```

```yaml
    env:
    - name: APP_MODE
      valueFrom: {configMapKeyRef: {name: app, key: MODE}}
    - name: DB_PASSWORD
      valueFrom: {secretKeyRef: {name: db, key: password}}
    envFrom:
    - configMapRef: {name: app}          # 모든 키 (prefix 로 접두사 가능)
    volumeMounts:
    - {name: cfg, mountPath: /etc/app}                                   # 디렉터리 전체 (다른 파일 가려짐)
    - {name: cfg, mountPath: /etc/nginx/app.properties, subPath: app.properties}   # 파일 하나 (갱신 안 됨)
  volumes:
  - name: cfg
    configMap: {name: app}
```

| 주입 방식 | ConfigMap 수정 반영 |
|---|---|
| env / envFrom | 안 됨 → 재시작 |
| 볼륨(디렉터리) | 됨 (1분 안팎) |
| 볼륨 + `subPath` | **안 됨** |

- `immutable: true` 로 만들면 데이터를 바꿀 수 없고, 바꾸려면 지우고 다시 만듭니다.
- Secret의 base64는 인코딩일 뿐 암호화가 아닙니다.

### 5.3 오토스케일링과 리소스 변경

```bash
k autoscale deploy web --cpu=50% --min=1 --max=4 $do > hpa.yaml   # 옛 kubectl 은 --cpu-percent=50
```

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata: {name: web}
spec:
  scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: web}
  minReplicas: 1
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: cpu
      target: {type: Utilization, averageUtilization: 50}
  behavior:                                  # 명령형 플래그 없음
    scaleDown:
      stabilizationWindowSeconds: 30         # 기본 300. 스케일 업 기본은 0
```

- `Utilization` 은 사용량 ÷ **requests**. requests가 없으면 `<unknown>`, metrics-server가 없어도 `<unknown>`.
- `target.type`: `Utilization`(퍼센트) / `AverageValue`(파드당 절대값) / `Value`(합계).

**In-place Pod resize (v1.35 GA)** — 실행 중인 파드의 CPU·메모리를 재시작 없이 바꿉니다.

```bash
k patch pod cache --subresource resize -p \
  '{"spec":{"containers":[{"name":"app","resources":{"requests":{"memory":"128Mi"},"limits":{"memory":"256Mi"}}}]}}'
k get pod cache -o jsonpath='{.status.containerStatuses[0].resources}{" "}{.status.containerStatuses[0].restartCount}'
```

- `--subresource resize` 없이 `edit`/`patch` 로 resources를 바꾸면 거부됩니다.
- **QoS 클래스는 바꿀 수 없습니다**(Burstable ↔ Guaranteed 전환 불가). 기본 `resizePolicy` 는 `NotRequired`(재시작 없음).
- 노드에 여유가 없으면 `PodResizePending`, 적용 중이면 `PodResizeInProgress` 컨디션.
- Deployment가 관리하는 파드는 템플릿이 그대로라, 오래 유지할 값은 템플릿(`kubectl set resources`)에 넣습니다.

### 5.4 자가 치유 기본 요소

**DaemonSet** — 생성 명령이 없으므로 Deployment dry-run yaml에서 `kind` 를 바꾸고 `replicas`·`strategy` 를 지웁니다.
컨트롤 플레인에도 띄우려면 toleration이 필요합니다.

```yaml
      tolerations:
      - {key: node-role.kubernetes.io/control-plane, operator: Exists, effect: NoSchedule}
```

**StatefulSet** — `serviceName`(헤드리스 서비스), 고정 이름 `<sts>-<ordinal>`, `volumeClaimTemplates` 로 replica별
PVC `<템플릿>-<sts>-<ordinal>`. 스케일 다운·삭제해도 PVC는 남습니다(`persistentVolumeClaimRetentionPolicy` 로 변경 가능).
`volumeClaimTemplates` 는 수정할 수 없습니다.

**Job / CronJob**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata: {name: cleanup}
spec:
  schedule: "*/10 * * * *"
  timeZone: "Asia/Seoul"                # 선택
  concurrencyPolicy: Forbid             # Allow | Forbid | Replace
  startingDeadlineSeconds: 30           # 이 시간 안에 못 뜨면 그 회차는 건너뜀
  successfulJobsHistoryLimit: 2
  failedJobsHistoryLimit: 1
  suspend: false
  jobTemplate:
    spec:
      completions: 1
      parallelism: 1
      backoffLimit: 3                   # 재시도 횟수 (파드는 최대 4개)
      activeDeadlineSeconds: 120        # backoffLimit 보다 우선
      ttlSecondsAfterFinished: 600
      template:
        spec:
          restartPolicy: Never          # Job 은 Never 또는 OnFailure 만
          containers:
          - {name: c, image: busybox:1.36, command: ["sh","-c","date; echo done"]}
```

```bash
k create job cleanup-manual --from=cronjob/cleanup    # 지금 한 번 실행
k patch cronjob cleanup -p '{"spec":{"suspend":true}}'
```

**Probe**

```yaml
        startupProbe:                    # 총 허용 시간 = periodSeconds × failureThreshold
          httpGet: {path: /, port: 80}
          periodSeconds: 5
          failureThreshold: 12
        readinessProbe:                  # 실패 → 트래픽에서 제외 (재시작 없음)
          httpGet: {path: /ready, port: 80}
          periodSeconds: 5
        livenessProbe:                   # 실패 → 컨테이너 재시작 (RESTARTS 증가)
          tcpSocket: {port: 80}
          periodSeconds: 10
          failureThreshold: 3
```

**PDB** — `k create pdb web --selector=app=web --min-available=2`. 자발적 중단(drain, eviction API)만 막습니다.
`kubectl delete pod` 나 노드 장애는 막지 못합니다. ALLOWED DISRUPTIONS가 0이면 drain이 계속 재시도합니다.

**네이티브 사이드카 (v1.33 GA)**

```yaml
spec:
  initContainers:
  - name: log-shipper
    image: busybox:1.36
    restartPolicy: Always                 # 이 한 줄이 사이드카로 만든다
    command: ["sh", "-c", "tail -n+1 -F /var/log/app/app.log"]
    volumeMounts: [{name: logs, mountPath: /var/log/app}]
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "while true; do date >> /var/log/app/app.log; sleep 5; done"]
    volumeMounts: [{name: logs, mountPath: /var/log/app}]
  volumes:
  - name: logs
    emptyDir: {}
```

앱보다 먼저 시작해 계속 돌고, 종료는 앱 뒤에 합니다. READY에 포함됩니다(2/2). `restartPolicy` 없는 일반 init 컨테이너에
`tail -F` 를 넣으면 파드가 `Init:0/1` 에서 멈춥니다. `-F` 는 파일이 아직 없어도 기다립니다.

### 5.5 스케줄링과 admission

| 방법 | 성격 |
|---|---|
| `nodeName` | 스케줄러를 **건너뜀** (taint·cordon 검사 없음) — 스케줄 가능 여부 확인에 쓰면 안 됨 |
| `nodeSelector` | 라벨 완전 일치 |
| node affinity | `required...`(못 맞추면 Pending) / `preferred...`(점수), 연산자 In·NotIn·Exists·DoesNotExist·Gt·Lt |
| pod (anti-)affinity | 다른 파드 기준, `topologyKey`(예: `kubernetes.io/hostname`) |
| taint / toleration | 노드가 거부, 파드가 면제 — **toleration은 허가일 뿐 끌어당기지 않음** |
| topologySpreadConstraints | `maxSkew`, `topologyKey`, `whenUnsatisfiable` |

```bash
k taint node worker02 dedicated=gpu:NoSchedule      # NoSchedule | PreferNoSchedule | NoExecute
k taint node worker02 dedicated-                    # 키 전체 제거
k label node worker02 accelerator=gpu
```

```yaml
  tolerations:
  - {key: dedicated, operator: Equal, value: gpu, effect: NoSchedule}
  nodeSelector: {accelerator: gpu}                   # 전용 노드 = taint + toleration + selector/affinity
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:                           # term 끼리 OR, matchExpressions 안은 AND
        - matchExpressions:
          - {key: tier, operator: In, values: [batch]}
```

**PriorityClass와 선점**

```bash
k get pc --sort-by=.value
k get pc -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.value}{"\n"}{end}' | grep -v '^system-' | sort -k2 -n | tail -1
```

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata: {name: high-priority}
value: 749999                    # 기존 사용자 정의 최댓값 - 1
globalDefault: false
preemptionPolicy: PreemptLowerPriority     # Never = 큐에서 앞서지만 남을 쫓아내지 않음
```

선점은 높은 우선순위 파드가 `Pending` 일 때만 일어납니다. `spec.priority` 는 admission이 채웁니다. 기존 Deployment에 적용하면
롤아웃이 일어납니다(`k patch deploy x -p '{"spec":{"template":{"spec":{"priorityClassName":"high-priority"}}}}'`).

**리소스와 QoS**

- 스케줄링은 **requests** 기준. CPU limit 초과 = 스로틀링, 메모리 limit 초과 = **OOMKilled**(137).
- QoS: 모든 컨테이너가 cpu·memory 둘 다 request = limit → `Guaranteed`, 하나라도 설정 → `Burstable`, 없음 → `BestEffort`.
- **replica 수로 노드 자원 나누기** 예: 노드 allocatable 2 CPU / 4Gi, 시스템 여유로 약 10~15% 남기고 3개로 나누면 파드당
  약 cpu 550m / memory 1Gi. **init 컨테이너에도 같은 값**을 넣습니다. 적용은 `scale --replicas=0` → 편집 → 원래 수로 복구.

**LimitRange / ResourceQuota**

```bash
k -n team-a create quota q --hard=requests.cpu=1,requests.memory=1Gi,limits.cpu=2,limits.memory=2Gi,pods=10
```

```yaml
apiVersion: v1
kind: LimitRange
metadata: {name: defaults, namespace: team-a}
spec:
  limits:
  - type: Container
    defaultRequest: {cpu: 100m, memory: 128Mi}    # requests 기본값
    default: {cpu: 200m, memory: 256Mi}           # limits 기본값 (이름 주의)
    max: {cpu: 500m}                              # 검증 (거부 기준)
```

쿼터가 requests·limits를 제한하면 그 값을 적지 않은 파드는 거부됩니다(`must specify ...`) → LimitRange 기본값으로 메웁니다.
LimitRange는 생성 시점에만 적용됩니다.

---

## 6. Services & Networking (20%)

### 6.1 파드 간 연결

모든 파드는 NAT 없이 서로의 IP로 통신합니다(CNI가 보장). 확인은 서로 다른 노드에 고정한 두 파드로 합니다.

```bash
k run a --image=nginx:1.27 --overrides='{"spec":{"nodeSelector":{"kubernetes.io/hostname":"worker01"}}}'
k run b --image=busybox:1.36 --restart=Never --overrides='{"spec":{"nodeSelector":{"kubernetes.io/hostname":"worker02"}}}' -- sleep 3600
k exec b -- wget -qO- --timeout=3 http://$(k get pod a -o jsonpath='{.status.podIP}')
```

### 6.2 Service

| 타입 | 용도 |
|---|---|
| ClusterIP | 클러스터 내부 가상 IP (기본) |
| NodePort | 모든 노드 IP의 포트 30000–32767 (ClusterIP 포함) |
| LoadBalancer | 외부 LB (베어메탈은 구현체 없으면 `<pending>`, NodePort 포함) |
| ExternalName | DNS CNAME |
| headless (`clusterIP: None`) | 가상 IP 없음, DNS가 파드 IP 목록을 돌려줌 (StatefulSet) |

```bash
k expose deploy web --port=80 --target-port=8080 --name=web          # expose: pod/svc/rc/deploy/rs (sts 불가)
k expose deploy web --name=web-headless --port=80 --cluster-ip=None
k create svc nodeport web-np --tcp=80:80 --node-port=30080           # 셀렉터가 app=web-np → 필요하면 교체
k set selector svc web-np app=web
k get endpointslice -l kubernetes.io/service-name=web                 # Endpoints 는 deprecated
curl http://<node-ip>:30080                                           # localhost 말고 노드 IP
```

- `port`(Service) / `targetPort`(컨테이너, 생략하면 port와 같음) / `nodePort`(노드).
- **이름 있는 포트**: 컨테이너 `ports: [{name: http, containerPort: 80}]` + Service `targetPort: http`.
- 셀렉터가 파드를 못 잡거나 파드가 Ready가 아니면 엔드포인트가 비고, 클라이언트는 **즉시 connection refused**.
  엔드포인트는 있는데 refused면 `targetPort` 가 실제 리스닝 포트와 다른 것입니다.

### 6.3 NetworkPolicy

- 어떤 정책이든 파드를 선택하면 그 방향(ingress/egress)이 **격리**되고, 정책들의 허용 규칙 **합집합**만 통과합니다.
- 연결 A→B는 **A의 egress와 B의 ingress가 둘 다** 허용되어야 합니다.
- egress를 막으면 **DNS도 막힙니다** → kube-system의 53/UDP·TCP를 엽니다.
- 거부는 보통 드롭이라 증상은 **timeout**(refused 아님). CNI가 NetworkPolicy를 지원해야 동작합니다.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: default-deny, namespace: payments}
spec:
  podSelector: {}                     # 네임스페이스의 모든 파드
  policyTypes: [Ingress, Egress]      # 규칙이 없으면 전부 거부
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: api-allow, namespace: payments}
spec:
  podSelector: {matchLabels: {app: api}}
  policyTypes: [Ingress, Egress]
  ingress:
  - from:
    - namespaceSelector: {matchLabels: {kubernetes.io/metadata.name: frontend}}
      podSelector: {matchLabels: {app: web}}        # 같은 항목 = AND ("-" 를 따로 달면 OR)
    ports: [{protocol: TCP, port: 8080}]
  egress:
  - to:
    - podSelector: {matchLabels: {app: db}}
    ports: [{protocol: TCP, port: 5432}]
  - to:
    - namespaceSelector: {matchLabels: {kubernetes.io/metadata.name: kube-system}}
      podSelector: {matchLabels: {k8s-app: kube-dns}}
    ports: [{protocol: UDP, port: 53}, {protocol: TCP, port: 53}]
```

- `podSelector: {}` = 이 네임스페이스의 모든 파드, `namespaceSelector: {}` = 모든 네임스페이스.
- `ipBlock: {cidr: 10.0.0.0/16, except: [10.0.5.0/24]}`, 포트 범위는 `port` + `endPort`.
- "가장 적게 여는 정책 고르기": 출발지(파드·네임스페이스)와 포트를 가장 좁게 지정하면서 요구 트래픽은 통과하는 것.

### 6.4 Gateway API

| 리소스 | 범위 | 누가 |
|---|---|---|
| GatewayClass | 클러스터 | 인프라 제공자 (컨트롤러 지정) |
| Gateway | 네임스페이스 | 플랫폼 팀 — listener(포트·프로토콜·호스트·TLS) |
| HTTPRoute (GRPCRoute …) | 네임스페이스 | 앱 팀 — 매칭·백엔드·필터 |
| ReferenceGrant | 네임스페이스 | 참조를 **받는** 쪽이 다른 네임스페이스의 참조를 허락 |

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: web-gw, namespace: web}
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes: {namespaces: {from: All}}     # 기본값 Same
  - name: https
    protocol: HTTPS
    port: 443
    hostname: shop.example.com
    tls:
      mode: Terminate
      certificateRefs: [{kind: Secret, name: shop-tls}]
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: shop, namespace: web}
spec:
  parentRefs:
  - {name: web-gw, sectionName: https}           # 다른 네임스페이스면 namespace: 추가
  hostnames: [shop.example.com]
  rules:
  - matches:
    - path: {type: PathPrefix, value: /api}
    backendRefs:
    - {name: api, port: 8080}                    # Service 의 port
  - matches:
    - headers: [{name: x-canary, value: "true"}]
    backendRefs:
    - {name: shop-v2, port: 80}
  - matches:
    - path: {type: PathPrefix, value: /}
    backendRefs:
    - {name: shop-v1, port: 80, weight: 90}      # weight 는 상대 비율, 생략 시 1
    - {name: shop-v2, port: 80, weight: 10}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: http-to-https, namespace: web}
spec:
  parentRefs: [{name: web-gw, sectionName: http}]
  hostnames: [shop.example.com]
  rules:
  - filters:
    - type: RequestRedirect
      requestRedirect: {scheme: https, statusCode: 301}
```

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1    # 설치된 버전은 kubectl api-resources 로 확인
kind: ReferenceGrant
metadata: {name: allow-web-gw, namespace: certs}  # Secret 이 있는 쪽
spec:
  from: [{group: gateway.networking.k8s.io, kind: Gateway, namespace: web}]
  to: [{group: "", kind: Secret}]
```

- 경로 필터 `URLRewrite`(`path: {type: ReplacePrefixMatch, replacePrefixMatch: /}`), `RequestHeaderModifier` 도 표준입니다.
- **우선순위**: Exact 경로 > 더 긴 Prefix > 메서드 > 헤더 매치 수 > 쿼리 매치 수. yaml 순서는 무관(Ingress도 가장 긴 경로 우선).
- listener `hostname` 과 route `hostnames` 는 교집합이 있어야 붙습니다.

**상태 읽기**

```bash
k get gatewayclass                                  # ACCEPTED True
k -n web get gateway web-gw                         # PROGRAMMED True, ADDRESS
k -n web get gateway web-gw -o jsonpath='{range .status.listeners[*]}{.name}{" routes="}{.attachedRoutes}{"\n"}{end}'
k -n web get httproute shop -o jsonpath='{range .status.parents[0].conditions[*]}{.type}={.status} ({.reason}){"\n"}{end}'
curl -H 'Host: shop.example.com' http://<gw-address>/api
curl -k --resolve shop.example.com:443:<gw-address> https://shop.example.com/
```

| 증상 | 의미 |
|---|---|
| route `Accepted=False (NotAllowedByListeners)` | listener의 allowedRoutes가 네임스페이스를 막음 |
| `Accepted=False (NoMatchingParent / NoMatchingListenerHostname)` | parentRefs 오타 / hostname 교집합 없음 |
| 모든 condition True인데 **404** | 요청 Host·경로가 route와 안 맞음 |
| `ResolvedRefs=False` + **500** | backendRef의 Service 이름·포트 없음, 또는 ReferenceGrant 없음(`RefNotPermitted`) |
| condition True인데 **503** | backend에 ready endpoint 없음 |
| listener `ResolvedRefs=False (InvalidCertificateRef)` | TLS Secret 없음·형식 오류 |

CRD 설치: `kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/<version>/standard-install.yaml`
(버전은 컨트롤러가 지원하는 것). 설치 버전은 CRD 어노테이션 `gateway.networking.k8s.io/bundle-version`.

### 6.5 Ingress

```bash
k get ingressclass
k -n echo create ingress echo --class=<class> --rule="example.org/echo*=echo-svc:8080"      # 끝에 * = Prefix, 없으면 Exact
k -n secure create ingress portal --class=<class> --rule="portal.example.com/*=portal:80,tls=portal-tls"
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: {name: portal, namespace: secure}
spec:
  ingressClassName: <class>
  tls:
  - {hosts: [portal.example.com], secretName: portal-tls}   # 같은 네임스페이스의 Secret만
  rules:
  - host: portal.example.com
    http:
      paths:
      - path: /
        pathType: Prefix              # 필수. Prefix(경로 요소 단위) | Exact | ImplementationSpecific
        backend:
          service: {name: portal, port: {number: 80}}
```

- 가장 긴 경로가 이깁니다. `/api` Prefix는 `/api/v1` 에 매칭되고 `/apifoo` 에는 안 됩니다.
- Ingress NGINX는 2026년 3월에 은퇴했습니다. 문제에 나온 IngressClass를 그대로 쓰고, 컨트롤러 전용 어노테이션에 기대지 않습니다.

**Ingress → Gateway API 대응표**

| Ingress | Gateway API |
|---|---|
| `ingressClassName` | Gateway `gatewayClassName` |
| `tls[].hosts` + `secretName` | listener `hostname` + `tls.certificateRefs` (`mode: Terminate`) |
| `rules[].host` | HTTPRoute `hostnames` |
| `path` + `pathType: Prefix`/`Exact` | `matches[].path` `PathPrefix`/`Exact` |
| `backend.service.name`/`port.number` | `backendRefs[].name`/`port` |
| 어노테이션(리다이렉트·리라이트) | `filters` (`RequestRedirect`, `URLRewrite`) |

이전 순서: Ingress 정보 추출 → Gateway(listener) → HTTPRoute → 새 경로 검증 → Ingress 삭제. ingress-nginx가 기본으로 하던
HTTP→HTTPS 리다이렉트는 자동이 아니므로 필요하면 `RequestRedirect` 로 선언합니다.

### 6.6 CoreDNS와 서비스 디스커버리

- Deployment `coredns`, Service **`kube-dns`**(ClusterIP 보통 `.10`), ConfigMap `coredns`(키 `Corefile`), 라벨 `k8s-app=kube-dns`.
- 이름 형식: Service `<svc>.<ns>.svc.cluster.local`, StatefulSet 파드 `<pod>.<serviceName>.<ns>.svc.cluster.local`,
  파드 `<ip-대시>.<ns>.pod.cluster.local`. `svc` 를 빼면(`web.beta.cluster.local`) NXDOMAIN.
- `/etc/resolv.conf`: `search <ns>.svc.cluster.local svc.cluster.local cluster.local`, `options ndots:5`. 짧은 이름은 **자기
  네임스페이스**로 풀립니다. 다른 네임스페이스는 최소 `<svc>.<ns>`.

| dnsPolicy | 동작 |
|---|---|
| `ClusterFirst` | 기본. 클러스터 DNS |
| `ClusterFirstWithHostNet` | `hostNetwork: true` 파드가 클러스터 DNS를 쓰려면 |
| `Default` | 노드의 resolv.conf |
| `None` | `dnsConfig` 로 직접 지정 |

```
.:53 {
    errors
    health { lameduck 5s }
    ready
    hosts {                       # 정적 레코드 추가
       10.0.0.50 db.internal
       fallthrough                # 없으면 나머지 이름이 여기서 끝나 버린다
    }
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    prometheus :9153
    forward . /etc/resolv.conf { max_concurrent 1000 }
    cache 30
    loop
    reload                        # ConfigMap 변경을 다시 읽음 (전파까지 1~2분) — 급하면 rollout restart
    loadbalance
}
```

```bash
k -n kube-system get cm coredns -o yaml > /opt/coredns-backup.yaml    # 수정 전 백업
k -n kube-system edit cm coredns
k -n kube-system rollout restart deploy coredns
k run t --rm -it --image=busybox:1.36 --restart=Never -- nslookup kubernetes.default.svc.cluster.local
```

**busybox `nslookup` 함정**: busybox 의 `nslookup` 은 점이 든 이름에 search 도메인을 붙이지 않습니다.
그래서 `nslookup kubernetes.default` 나 `nslookup web.beta` 는 DNS가 정상이어도 NXDOMAIN 이 납니다. busybox 로는
FQDN(`...svc.cluster.local`)이나 점 없는 이름(`web`)만 조회합니다. 짧은 이름을 제대로 확인하려면 공식 DNS 디버깅 문서의
`registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3` 이미지를 씁니다. 이 이미지의 `nslookup` 은 search 와 `ndots` 를 따릅니다.
`wget`·`curl` 처럼 libc 리졸버를 쓰는 프로그램은 busybox 안에서도 search 를 적용하므로 `wget http://web.beta` 는 됩니다.

---

## 7. Storage (10%)

### 7.1 PV·PVC 바인딩

| 조건 | 기준 |
|---|---|
| accessModes | PVC가 요청한 모드가 PV 목록에 포함 |
| storageClassName | 문자열 완전 일치 |
| 용량 | PV capacity ≥ PVC request (바인딩되면 PV 전체 차지) |

- `storageClassName` **생략** = 기본 StorageClass(동적 프로비저닝), `""` = 클래스 없는 PV에만.
- 같은 조건의 PV가 여럿이면 PVC `spec.volumeName: <pv>` 로 고정합니다.
- 액세스 모드: RWO(**노드** 하나), RWOP(파드 하나), ROX, RWX. `volumeMode: Block` 은 파드에서 `volumeDevices`+`devicePath`.
- hostPath·local PV는 노드 로컬이라 PV에 `nodeAffinity` 를 붙입니다(`local` 은 필수).

```yaml
apiVersion: v1
kind: PersistentVolume
metadata: {name: pv-logs}
spec:
  capacity: {storage: 2Gi}
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath: {path: /mnt/data/logs}
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions: [{key: kubernetes.io/hostname, operator: In, values: [worker01]}]
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: pvc-logs, namespace: ops}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: manual
  volumeName: pv-logs                 # 선택: 특정 PV에 고정
  resources: {requests: {storage: 1Gi}}
```

### 7.2 반환 정책(reclaim)

| 정책 | PVC 삭제 후 |
|---|---|
| `Retain` | PV `Released`, 데이터 보존. `spec.claimRef` 를 지워야 `Available` |
| `Delete` | 플러그인이 실제 볼륨과 PV 삭제. 삭제를 못 하면(정적 hostPath 등) **`Failed`** |
| `Recycle` | deprecated |

```bash
k patch pv pv-retain -p '{"spec":{"claimRef":null}}'                              # Released → Available
k patch pv <pv> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'           # 기존 PV 보호
```

StorageClass의 `reclaimPolicy` 는 **새로 만들어지는 PV**에만 적용됩니다. 기존 PV는 위처럼 직접 바꿉니다.

### 7.3 StorageClass와 동적 프로비저닝

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-fast
  annotations: {storageclass.kubernetes.io/is-default-class: "true"}
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer      # 파드가 쓸 때까지 PVC Pending (정상)
allowVolumeExpansion: false
```

```bash
k patch sc standard -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
k get sc                                      # (default) 는 하나만
```

- default가 여럿이면 가장 최근 것이 쓰이지만, 하나만 남기는 것이 원칙입니다.
- `provisioner`·`parameters`·`reclaimPolicy`·`volumeBindingMode` 는 불변, `allowVolumeExpansion` 은 변경 가능.
- **확장**: PVC의 `spec.resources.requests.storage` 를 키움 → `status.capacity` 가 바뀌면 완료. 실제로 늘리는 것은 드라이버라
  local-path처럼 확장을 지원하지 않으면 끝나지 않습니다. 오프라인 확장만 되는 드라이버면 `FileSystemResizePending` → 파드 재시작.
  실제 용량 아래로 줄이는 것은 불가능합니다.

### 7.4 볼륨 타입

```yaml
  volumes:
  - name: scratch
    emptyDir: {medium: Memory, sizeLimit: 64Mi}     # 파드와 수명이 같음. Memory 는 메모리 사용량에 포함
  - name: host
    hostPath: {path: /var/log, type: Directory}     # 노드 로컬
  - name: all-in-one
    projected:
      sources:
      - secret: {name: db-cred, items: [{key: password, path: password}]}
      - configMap: {name: app-cfg, items: [{key: app.conf, path: app.conf}]}
      - downwardAPI: {items: [{path: labels, fieldRef: {fieldPath: metadata.labels}}]}
  - name: data
    persistentVolumeClaim: {claimName: app-data}
```

**Retain PV 재사용 흐름**(Deployment가 지워진 경우): PV 상태 확인(`Released` 면 claimRef 제거) → 같은 클래스·모드·용량의 PVC를
`volumeName` 으로 만들기 → Deployment 매니페스트의 `volumes`/`volumeMounts` 에 PVC 연결 → apply → PVC `Bound`, 파드 Running.

---

## 8. Troubleshooting (30%)

### 8.1 접근법 — 증상에서 계층으로

| 증상 | 먼저 볼 것 |
|---|---|
| `kubectl` 이 connection refused | `ss -lntp \| grep 6443`, kubeconfig `server:`, `crictl ps -a` |
| 노드 NotReady | `k describe node` Conditions → 노드의 `systemctl status kubelet`, `journalctl -u kubelet` |
| 파드 Pending | `k describe pod` Events (이벤트가 **없으면** 스케줄러) |
| 파드 ContainerCreating | Events의 `FailedCreatePodSandBox`(CNI) / `MountVolume`(볼륨) / `not found`(ConfigMap·Secret) |
| 파드 CrashLoopBackOff | `lastState.terminated`(exit code, reason), `logs --previous` |
| 서비스 안 됨 | DNS → EndpointSlice → targetPort → kube-proxy → NetworkPolicy |
| `kubectl top` 실패 | `k get apiservices \| grep metrics` → metrics-server 파드·로그 |

### 8.2 노드 NotReady

```bash
k describe node worker01 | grep -A10 Conditions
# Ready=Unknown "Kubelet stopped posting node status" → kubelet 이 보고를 못 함 (죽음·API 도달 불가)
# Ready=False + 메시지 → kubelet 은 살아 있고 문제를 보고 중 (CNI 등)
ssh worker01; sudo -i
systemctl status kubelet; journalctl -u kubelet -n 50 --no-pager
systemctl status containerd
systemctl cat kubelet                   # 유닛 + 드롭인(10-kubeadm.conf) 실제 경로
cat /var/lib/kubelet/config.yaml        # containerRuntimeEndpoint, staticPodPath, cgroupDriver, clusterDNS
cat /etc/kubernetes/kubelet.conf        # API server 주소, 클라이언트 인증서
```

| 로그·상태 | 원인 | 조치 |
|---|---|---|
| `inactive (dead)`, `disabled` | kubelet 꺼짐 | `systemctl enable --now kubelet` |
| `activating (auto-restart)` + config 오류 | `/var/lib/kubelet/config.yaml` 오타 | 수정 → `systemctl restart kubelet` |
| 런타임 엔드포인트에 연결 못 함 | containerd 꺼짐 / 엔드포인트 오타 | `systemctl enable --now containerd` / config 수정 |
| `running with swap on is not supported` | swap 켜짐 | `swapoff -a` + fstab |
| `unknown flag: --xyz` | 드롭인 인자 오류 | 드롭인 수정 → **`daemon-reload`** → restart |
| `connection refused` to :6443 | API 주소 오류·컨트롤 플레인 다운 | kubelet.conf `server:`, 컨트롤 플레인 확인 |
| `Unauthorized`, 인증서 만료 | kubelet 클라이언트 인증서 만료 | `kubeadm kubeconfig user --org system:nodes --client-name system:node:<n>` 로 재발급 |
| `cni plugin not initialized` | CNI 설정 없음 | CNI DaemonSet 확인 (kubelet은 정상) |

유닛 파일·드롭인을 고쳤으면 `systemctl daemon-reload` 가 먼저이고, `config.yaml` 만 고쳤으면 restart만 합니다.
복구 확인은 `nodeSelector` 로 테스트 파드를 그 노드에 띄워서 합니다(`nodeName` 은 스케줄러를 건너뜀).

### 8.3 컨트롤 플레인 컴포넌트

```bash
ssh cp01; sudo -i
ss -lntp | grep 6443                    # 아무도 안 듣는가
crictl ps -a | grep -E 'kube-apiserver|etcd|scheduler|controller'
crictl logs <id>                        # 컨테이너가 떴다 죽은 경우
journalctl -u kubelet --since '10 min ago' | grep -iE 'manifest|error'   # 파드가 아예 안 생긴 경우 (yaml 파싱)
cp /etc/kubernetes/manifests/kube-apiserver.yaml /root/                  # 백업은 반드시 디렉터리 밖
vi /etc/kubernetes/manifests/kube-apiserver.yaml                         # 저장하면 kubelet 이 재생성
```

| 컴포넌트 | 고장 증상 |
|---|---|
| kube-apiserver | `kubectl` 전체 실패 (refused) |
| etcd | apiserver가 etcd 연결 오류로 죽음 |
| kube-scheduler | 새 파드가 **이벤트 없이** Pending |
| kube-controller-manager | Deployment를 만들어도 ReplicaSet·파드가 안 생김, EndpointSlice 갱신 안 됨 |

| 매니페스트 흔한 오류 | 확인 |
|---|---|
| yaml 들여쓰기·문법 | kubelet 로그 `Could not process manifest file` |
| 플래그 철자 | `crictl logs` 의 `unknown flag` |
| `--etcd-servers` 주소 (이전 후 옛 IP 등) | stacked kubeadm은 `https://127.0.0.1:2379` |
| 인증서·kubeconfig 경로 | 플래그와 `volumes[].hostPath` 둘 다 맞아야 함 (`FileOrCreate` 는 틀린 경로에 빈 파일을 만든다) |
| 이미지 태그 오타 | 다른 컨트롤 플레인 매니페스트의 태그와 비교 |

- kubelet은 매니페스트 디렉터리에서 점(`.`)으로 시작하지 않는 **모든 파일**을 읽습니다. `.bak` 도 읽습니다.
- 정적 파드를 강제로 다시 만들려면 파일을 디렉터리 밖으로 옮겼다가(약 20초) 되돌립니다. 미러 파드는 `kubectl delete` 해도 바로 돌아옵니다.
- `kubectl` 이 refused인데 6443이 멀쩡히 열려 있으면 kubeconfig의 `server` 주소·포트가 틀린 것입니다(`k config view --minify`).
  인증서·사용자 문제는 연결은 되고 `x509`/`Unauthorized`/`Forbidden` 으로 나옵니다.
- 스케줄러 헬스는 노드에서 `curl -k https://127.0.0.1:10259/healthz`(API server의 `/readyz` 에는 없음).

### 8.4 파드 상태별 원인

| 상태 | 흔한 원인 |
|---|---|
| Pending | `Insufficient cpu/memory`, `untolerated taint`, node affinity/selector 불일치, PVC 미바인딩, (이벤트 없음 → 스케줄러) |
| ContainerCreating | CNI(`FailedCreatePodSandBox`), 볼륨 마운트, ConfigMap/Secret 없음 |
| ImagePullBackOff | 태그·이미지 이름 오타, 레지스트리 인증(`imagePullSecrets`) |
| CrashLoopBackOff | 앱 오류, 잘못된 command, liveness 실패, OOM |
| Running, READY 0/1 | readiness 실패 (재시작 없음) |
| Evicted (Failed) | 노드 압박 — `k get pods -A --field-selector=status.phase=Failed` |
| Terminating 정체 | 노드 연결 끊김, finalizer |

| exit code | 의미 |
|---|---|
| 0 | 정상 종료 — 포그라운드 프로세스가 없어 바로 끝남 (RESTARTS 증가) |
| 1, 2 | 앱 오류 |
| 126 | 실행 권한 없음 |
| 127 | command not found (오타, 이미지에 없음) |
| 137 | SIGKILL — `reason: OOMKilled` 면 메모리 limit 초과 |
| 139 | segfault |
| 143 | SIGTERM (probe 실패로 kubelet이 종료 등) |

```bash
k get pod p -o jsonpath='{.status.containerStatuses[0].lastState.terminated}'
k logs p --previous
k describe pod p | grep -A5 'Last State'
k get events -n ns --sort-by=.lastTimestamp | tail
```

- 파드 필드는 대부분 불변입니다. 이미지와(1.35부터 `--subresource resize` 로) CPU·메모리만 제자리 변경. 나머지는
  `k get pod p -o yaml > p.yaml` → 수정 → `k replace --force -f p.yaml`.
- Deployment가 관리하는 파드는 파드가 아니라 Deployment를 고칩니다.

### 8.5 서비스·네트워크

```bash
k -n app get svc web; k -n app get endpointslice -l kubernetes.io/service-name=web
k -n app get pods -l <svc 셀렉터> --show-labels             # 셀렉터가 파드를 잡는가
k run t --rm -it --image=busybox:1.36 --restart=Never -- wget -qO- --timeout=3 http://web.app
k -n kube-system get pods -l k8s-app=kube-proxy -o wide     # 노드마다 하나씩 있는가 (DS DESIRED = 노드 수?)
k -n kube-system get cm kube-proxy -o yaml | grep -E '^\s+mode:'   # "" = iptables
iptables-save | grep <clusterIP>                            # iptables 모드 (노드에서)
nft list table ip kube-proxy                                # nftables 모드
```

- **즉시 refused** = 누군가 거절(엔드포인트 없음에 대한 거부 룰, 파드가 그 포트를 안 들음). **hang/timeout** = 패킷이 버려짐
  (룰 없음, NetworkPolicy).
- kube-proxy는 멈춰도 기존 룰을 지우지 않습니다. 룰이 "없다"면 재부팅·flush가 겹친 것입니다.
- 한 노드만 이상하면 **테스트 파드를 그 노드에 고정**해서 확인합니다. 그 노드에 kube-proxy가 없으면 DNS(kube-dns ClusterIP)도
  같이 안 되므로, CoreDNS 파드 IP로 직접 물어 DNS와 변환 문제를 가릅니다.
- DNS가 전부 안 되면: kube-dns EndpointSlice 비었나(CoreDNS 0개·CrashLoop) → Corefile 문법 → `loop` 플러그인 오류 → kubelet
  `clusterDNS` 가 kube-dns ClusterIP와 같은지.

### 8.6 리소스 사용량 모니터링

```bash
k top node --sort-by=cpu
k top pod -A --sort-by=memory
k top pod -n batch --sort-by=cpu --no-headers | head -1 | awk '{print $1}'
k top pod analytics -n monitoring --containers
k describe node worker01 | grep -A8 'Allocated resources'   # requests·limits 합계
k get --raw "/api/v1/nodes/worker01/proxy/configz"          # kubelet 실효 설정
```

`kubectl top` 이 `Metrics API not available` 이면: `k get apiservices | grep metrics`(`False (MissingEndpoints)` =
metrics-server 파드가 Ready 아님) → `k -n kube-system logs deploy/metrics-server` → `x509 ... doesn't contain any IP SANs` 이면
Deployment args에 `--kubelet-insecure-tls` 추가.

### 8.7 컨테이너 출력 스트림

| 명령 | 의미 |
|---|---|
| `k logs p -c c` | 컨테이너 지정. **`-c` 를 빼면 에러 없이 첫 컨테이너**(또는 `kubectl.kubernetes.io/default-container` 어노테이션)를 고르고 stderr에 `Defaulted container ...` |
| `--previous` / `-p` | 마지막으로 죽은 인스턴스 |
| `--all-containers --prefix` | init 포함 전부, 줄마다 `[pod/p/c]` (`-c` 와 같이 쓰면 에러) |
| `-l app=x` | 셀렉터의 모든 파드 — **기본 `--tail` 이 파드당 10줄** (`--tail=-1` 로 전부) |
| `deploy/x` | 그 Deployment의 파드 **하나** |
| `--since=10m`, `--since-time=RFC3339`, `--timestamps`, `--tail=20`, `-f` | 시간·개수·실시간 (`-f` 로 5개 넘는 파드는 `--max-log-requests`) |

- stdout과 stderr는 한 로그로 합쳐집니다. 노드의 실제 파일은 `/var/log/pods/<ns>_<pod>_<uid>/<container>/<N>.log`
  (`/var/log/containers/*.log` 는 링크), N은 재시작 횟수. 노드에서는 `crictl logs [-p] <id>`.
- 사이드카(initContainers에 있어도)의 로그도 `-c <이름>` 으로 봅니다.

### 8.8 노드 압박과 축출

- `DiskPressure`/`MemoryPressure=True` → 노드에 `node.kubernetes.io/disk-pressure:NoSchedule` 류 taint → 새 파드 Pending.
- 기본 하드 축출 임계(리눅스): `memory.available<100Mi`, `nodefs.available<10%`, `nodefs.inodesFree<5%`, `imagefs.available<15%`.
  실효값은 `configz` 로 봅니다(kubeadm의 config.yaml에는 보통 적혀 있지 않음).
- kubelet은 파드를 축출하기 **전에** 안 쓰는 이미지·죽은 컨테이너를 먼저 정리합니다. 회수는 `crictl rmi --prune`,
  `journalctl --vacuum-size=200M`, 큰 로그·emptyDir 찾기(`du -sh /var/log/pods/* /var/lib/kubelet/pods/*`).
  `/var/lib/containerd` 를 손으로 지우지 않습니다.
- 공간을 비워도 `evictionPressureTransitionPeriod`(기본 5분) 동안 컨디션이 유지됩니다.
- 축출(Evicted)은 kubelet이 파드 전체를 종료, OOMKilled는 커널이 컨테이너 하나를 SIGKILL(파드는 남고 RESTARTS 증가).

---

## 9. 자주 틀리는 함정 40선

1. 지정 호스트로 `ssh` 하지 않고 작업 → 0점. 끝나면 `exit`.
2. 네임스페이스 빠뜨림. `-n` 또는 매니페스트 `namespace:`.
3. `$do`(`--dry-run=client -o yaml`)를 `--` 뒤에 쓰면 컨테이너 인자가 되어 오브젝트가 실제로 생성됨.
4. `kubectl run` 에는 `--requests`/`--limits` 가 없음 → yaml 또는 `kubectl set resources`.
5. `kubectl set image deploy/x <컨테이너이름>=...` — 가운데는 Deployment 이름이 아니라 **컨테이너 이름**.
6. `auth can-i update deployments/scale` 은 `scale` 을 이름으로 읽음 → `--subresource=scale`.
7. RBAC `apiGroups` 오류: deployments는 `apps`, pods는 `""`, CRD는 그 group.
8. 인증서는 권한을 주지 않음. CN=사용자, O=그룹. `kubectl config` 에 `--kubeconfig` 빠뜨리면 내 설정이 바뀜.
9. kubeadm 업그레이드 때 **노드마다** 저장소 버전 변경. 워커·두 번째 컨트롤 플레인은 `upgrade node`.
10. 유닛·드롭인 수정 후 `daemon-reload` 없이 restart.
11. `kubeadm certs renew` 후 정적 파드 재시작 안 함.
12. 정적 파드 매니페스트 백업을 디렉터리 안에 둠(`.bak` 도 읽힘).
13. `crictl pods -a` 는 없는 플래그. `crictl ps -a` 는 필요.
14. Helm `upgrade` 에 `--reuse-values` 빠뜨림. `--version` 고정 안 함.
15. Kustomize는 `kubectl apply -k`. `replicas`/`patches` 이름은 접두사 전 이름. `commonLabels` 는 셀렉터까지 바꿈.
16. CRD 이름은 `<plural>.<group>`. CRD 삭제 = 모든 인스턴스 삭제.
17. Flannel은 NetworkPolicy를 적용하지 않음. CNI IP 풀은 클러스터 pod CIDR과 일치.
18. HPA `<unknown>` = requests 없음 또는 metrics-server 없음. `behavior` 는 yaml로.
19. `kubectl autoscale --cpu=50%` (`--cpu-percent` 는 deprecated).
20. 사이드카는 `initContainers` + `restartPolicy: Always`. 일반 init 컨테이너에 `tail -F` 는 영원히 대기.
21. 파드 리소스 제자리 변경은 `--subresource resize`, QoS 클래스는 못 바꿈.
22. `Guaranteed` 는 모든 컨테이너의 cpu·memory 둘 다 request = limit.
23. toleration만으로는 특정 노드로 가지 않음 — selector/affinity 필요.
24. 스케줄 가능 여부를 `nodeName` 으로 확인 → 스케줄러를 건너뛰어 의미 없음.
25. 쿼터가 있으면 리소스 없는 파드 거부 → LimitRange. `default`=limits, `defaultRequest`=requests.
26. PriorityClass "기존 최댓값 - 1" 은 `system-*` 제외, 새 클래스를 만들기 **전에** 계산.
27. Job `backoffLimit` 은 재시도 횟수(파드는 +1). `restartPolicy: Always` 는 Job에서 거부.
28. `targetPort` 생략 = `port` 와 같음. Service 포트 ≠ 컨테이너 포트 혼동.
29. `kubectl expose` 는 StatefulSet 불가 → `kubectl create service clusterip <이름> --clusterip=None` + `set selector`, 또는 yaml. (`expose` 는 `--cluster-ip`, `create service` 는 `--clusterip` — 철자가 다름)
30. `kubectl get endpoints` 대신 EndpointSlice(`-l kubernetes.io/service-name=`).
31. NetworkPolicy: 같은 `-` 항목 = AND, 따로 = OR. egress 막으면 DNS도 막힘. 연결은 양 끝 모두 허용 필요.
32. Gateway `allowedRoutes` 기본 `Same`, `backendRefs.port` 는 Service 포트, `sectionName` 은 listener **이름**.
33. Gateway 404(매칭 없음) / 500(backendRef 무효) / 503(endpoint 없음) 구분.
34. Ingress `pathType` 필수. TLS Secret은 같은 네임스페이스, 키는 `tls.crt`/`tls.key`.
35. Service FQDN은 `<svc>.<ns>.svc.cluster.local` — `svc` 빠뜨림. 다른 네임스페이스는 최소 `<svc>.<ns>`. busybox `nslookup` 은 점이 든 이름에 search를 안 붙이므로 FQDN으로 조회.
36. `storageClassName` 생략(기본 클래스) vs `""`(클래스 없음). 같은 조건 PV가 여럿이면 `volumeName`.
37. `Retain` PV는 `Released` → `claimRef` 제거해야 재사용. hostPath + `Delete` 는 `Failed`.
38. `WaitForFirstConsumer` 클래스의 PVC `Pending` 은 정상. local-path는 확장 불가.
39. `kubectl logs` 에서 `-c` 빠뜨리면 조용히 첫 컨테이너. `-l` 은 기본 10줄. 죽은 인스턴스는 `--previous`.
40. etcd 복구는 `etcdutl snapshot restore`(3.6에서 `etcdctl` 복구 제거).

---

## 10. 시험 당일 체크리스트

**시작 전**

- [ ] 신분증, 책상 정리, 웹캠·마이크, 조용한 방. 시험 시작 30분 전 입장 절차.
- [ ] 이 문서의 [9. 함정 40선](#9-자주-틀리는-함정-40선)을 한 번 더 읽기.

**매 문제**

- [ ] 호스트·네임스페이스·이름·파일 경로 확인 → `ssh <host>`
- [ ] 명령형으로 뼈대 → 필요하면 yaml 편집 → 적용
- [ ] `get`/`describe`/`cat` 으로 결과 확인
- [ ] `exit` 로 베이스 터미널 복귀
- [ ] 3분 안에 진입점이 없으면 flag 후 다음 문제

**마지막 10분**

- [ ] flag 문제 중 부분 점수를 딸 수 있는 단계부터
- [ ] 출력 파일들이 정확한 경로에 있는지 `cat`
- [ ] 롤아웃·정적 파드처럼 기다렸던 것들이 Running/Ready인지 확인

---

## 11. 연습 문제 매핑

주제별로 어떤 연습 문제를 풀면 되는지입니다. `A01` = `mock_exam_a` 의 q01. D·E·F 세트는 기본 난이도, A·B·C는 심화입니다.

| 주제 | 기본 (D·E·F) | 심화 (A·B·C) |
|---|---|---|
| RBAC·사용자 | D02, F02 | A01, A04, C04 |
| 노드 준비·CRI | E01, F04 | B02, B04, C01 |
| kubeadm 업그레이드·조인·인증서 | D04, F03 | A02, C01 |
| HA 컨트롤 플레인·etcd | E04 | B01 |
| Helm | D01, F01 | A03 |
| Kustomize | E02 | C02 |
| CRD·operator | D03, E03 | B03, C04 |
| CNI 설치 | — | C03 |
| Deployment 롤아웃 | D05 | A05 |
| ConfigMap·Secret | D06, F06 | A06 |
| 스케줄링(taint·affinity·priority) | D07, F05 | A07, B07 |
| 리소스·쿼터·QoS | E06 | B06, C14 |
| HPA | E05 | B05 |
| 사이드카 | E07, D16 | A16, C15 |
| Job·CronJob | F07 | C07 |
| probe·PDB·StatefulSet·DaemonSet | — | C05, C06 |
| Service 타입·포트 | D09, E10 | A08 |
| Gateway API | D08, E08, F08 | B08, B14, C08, C09 |
| Ingress | E09, F08 | A09, C09 |
| NetworkPolicy | D10, F09 | B09, C03 |
| DNS·CoreDNS | E16, F10 | A10, B10, C10, C13 |
| PV·PVC·reclaim | D12, E11, F11 | A11, A12, C12 |
| StorageClass·확장 | D11 | B11, C12 |
| 볼륨 타입·Block | E12, F12 | B12, C11 |
| 노드 NotReady | D13, E14, F13 | A13, B17 |
| 컨트롤 플레인 장애 | D14, E13, F14 | A17, B16 |
| 파드 장애(CrashLoop·OOM) | E15 | A14, C14 |
| 서비스 장애 | D15, F15 | A15, C17 |
| 리소스 모니터링·resize | D17, E17, F17 | B13, C14 |
| 로그 | D16, F16 | A16, C15 |
| CNI·kube-proxy 장애 | — | B15, C17 |
| 노드 압박·축출 | — | C16 |
