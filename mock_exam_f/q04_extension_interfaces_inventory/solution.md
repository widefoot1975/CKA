# q04 — Identify the CRI, CNI and CSI in use · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

클러스터 `k8s-c1` 이 어떤 컨테이너 런타임, 네트워크 플러그인, 스토리지 드라이버를 쓰는지 기록한다.
답 파일은 모두 `k8s-c1` 에 쓰고, 노드 로컬 파일은 `worker01` 에서 읽는다.

1. 각 노드의 이름과 그 노드가 보고하는 컨테이너 런타임(버전 포함)을 한 줄에 한 노드씩
   `/opt/course/f04/runtime.txt` 에 쓴다.
2. `worker01` 에서 `/var/lib/kubelet/config.yaml` 에 설정된 `containerRuntimeEndpoint` 를 찾아 그 값을
   `/opt/course/f04/endpoint.txt` 에 쓴다.
3. `worker01` 의 컨테이너 런타임은 `/etc/cni/net.d/` 에서 이름순으로 첫 번째 파일을 쓴다. 그 파일 이름과
   파일 안 첫 번째 플러그인의 `type` 을 `<파일> <type>` 형식으로 `/opt/course/f04/cni.txt` 에 쓴다.
4. 클러스터에 등록된 모든 CSI 드라이버의 이름을 한 줄에 하나씩 `/opt/course/f04/csi.txt` 에 쓴다.

## 모범 풀이

**1) CRI — 노드가 보고하는 런타임 (k8s-c1)**

```bash
mkdir -p /opt/course/f04
kubectl get nodes -o wide                  # CONTAINER-RUNTIME 열
kubectl get nodes --no-headers \
  -o custom-columns=NAME:.metadata.name,RUNTIME:.status.nodeInfo.containerRuntimeVersion \
  > /opt/course/f04/runtime.txt
cat /opt/course/f04/runtime.txt
# cp01       containerd://2.1.4            (버전은 예시)
# worker01   containerd://2.1.4
```

**2~3) 노드 로컬 설정 — kubelet 의 CRI 엔드포인트와 CNI 설정 (worker01)**

```bash
ssh worker01
sudo -i
grep containerRuntimeEndpoint /var/lib/kubelet/config.yaml
# containerRuntimeEndpoint: unix:///var/run/containerd/containerd.sock
ls /etc/cni/net.d/                         # ls 는 이름순으로 정렬해 보여 준다
# 10-flannel.conflist                      (예시 — Calico 라면 10-calico.conflist)
grep -m1 '"type"' /etc/cni/net.d/10-flannel.conflist
#       "type": "flannel",
exit; exit                                 # k8s-c1 로 돌아와 답을 쓴다

echo 'unix:///var/run/containerd/containerd.sock' > /opt/course/f04/endpoint.txt
echo '10-flannel.conflist flannel' > /opt/course/f04/cni.txt
```

오래된 kubeadm 으로 만든 노드에서는 엔드포인트가 `config.yaml` 대신 `/var/lib/kubelet/kubeadm-flags.env`
의 `--container-runtime-endpoint` 플래그에 들어 있기도 합니다.

**4) CSI — 클러스터에 등록된 드라이버 (k8s-c1)**

```bash
kubectl get csidrivers
# NAME                  ATTACHREQUIRED   PODINFOONMOUNT   ...
# hostpath.csi.k8s.io   true             true             ...      (예시)
kubectl get csidrivers --no-headers -o custom-columns=NAME:.metadata.name > /opt/course/f04/csi.txt
```

**핵심 — 세 인터페이스는 보이는 곳이 다릅니다.**

| 인터페이스 | 누가 무엇을 호출하나 | 어디서 확인하나 |
|---|---|---|
| CRI | kubelet → 컨테이너 런타임 (유닉스 소켓 위 gRPC) | `kubectl get nodes -o wide`, kubelet 의 `containerRuntimeEndpoint` |
| CNI | 컨테이너 런타임 → CNI 플러그인 (파드 네트워크 구성) | 노드의 `/etc/cni/net.d/` (설정), `/opt/cni/bin/` (플러그인 바이너리) |
| CSI | kubelet·CSI 컨트롤러 → CSI 드라이버 (볼륨 생성·연결·마운트) | `kubectl get csidrivers`, 노드별 등록은 `kubectl get csinodes` |

CNI 는 kubelet 이 아니라 **컨테이너 런타임(containerd)이 호출**합니다. 그래서 CNI 설정은 API 오브젝트가
아니라 노드의 파일로만 보입니다. 예전 CNI 의 설정 파일이 이름순으로 앞에 남아 있으면 그 파일이 쓰이므로
"이름순 첫 파일"이 실제로 쓰이는 설정입니다.

## 검증

```bash
cat /opt/course/f04/runtime.txt /opt/course/f04/endpoint.txt /opt/course/f04/cni.txt /opt/course/f04/csi.txt
ssh worker01 sudo ls -l /run/containerd/containerd.sock     # 엔드포인트의 소켓이 실제로 있음
kubectl get csinodes -o custom-columns='NODE:.metadata.name,DRIVERS:.spec.drivers[*].name'
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: CRI 는 노드 상태(`containerRuntimeVersion`)와 kubelet 설정(`containerRuntimeEndpoint`), CNI 는 노드의 `/etc/cni/net.d/`, CSI 는 `kubectl get csidrivers`.
- **헷갈리는 지점**: StorageClass 의 provisioner 가 모두 CSI 드라이버는 아닙니다. 예를 들어 `rancher.io/local-path` 는 CSIDriver 로 등록되지 않으므로 `kubectl get csidrivers` 에 나오지 않습니다. 또 `/var/run` 은 `/run` 을 가리키는 심볼릭 링크라서 `unix:///var/run/containerd/containerd.sock` 과 `unix:///run/containerd/containerd.sock` 은 같은 소켓입니다.

## 참고 문서

- 검색어: `container runtimes`, `network plugins`, `csi volume`
- https://kubernetes.io/docs/setup/production-environment/container-runtimes/
- https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/
- https://kubernetes.io/docs/concepts/storage/volumes/#csi
- https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
