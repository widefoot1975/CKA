# q04 — Identify the CRI, CNI and CSI in use

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh worker01` for the node steps |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

클러스터에 이미 있는 런타임·CNI·CSI 를 조사하는 문제라 대부분 만들 것이 없다. 답 디렉터리를 비우고,
CSI 드라이버가 하나도 등록되어 있지 않은 실습 클러스터라면 4번 답이 빈 파일이 되지 않도록 연습용 CSIDriver
등록 오브젝트를 하나 만든다.
`k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 노드 worker01 이 있는지 확인
kubectl get node worker01

# 1) 이전 실습 흔적 정리 — 답 파일 디렉터리
sudo rm -rf /opt/course/f04
sudo mkdir -p /opt/course/f04 && sudo chown $(id -u):$(id -g) /opt/course/f04

# 2) CSI 드라이버가 하나도 없을 때만 — 연습용 CSIDriver 등록 오브젝트 (kubectl create 로는 못 만들어서 YAML)
kubectl get csidrivers
kubectl apply -f - <<'YAML'
apiVersion: storage.k8s.io/v1
kind: CSIDriver
metadata:
  name: hostpath.csi.k8s.io
  labels: {practice: f04}
spec:
  attachRequired: false
  podInfoOnMount: true
  volumeLifecycleModes: [Persistent]
YAML

# 3) 시작 상태 확인
kubectl get nodes -o wide
kubectl get csidrivers
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/f04` 는 비어 있고 `kubectl get csidrivers` 에 드라이버가 한 개 이상 보인다. 스크립트는
이미 드라이버가 있으면 아무것도 만들지 않는다.
연습용 `hostpath.csi.k8s.io` 는 **등록 정보(CSIDriver 오브젝트)만** 있고 실제 드라이버 파드는 없다. 이 문제는
"등록된 드라이버 이름"을 묻기 때문에 그것으로 충분하지만, 이 드라이버로 볼륨을 만들 수는 없다.
`/etc/cni/net.d/` 와 kubelet 설정은 `worker01` 에 원래 있는 것을 그대로 읽는다. CNI 를 바꾼 적이 있다면 옛 설정
파일이 이름순으로 앞에 남아 있을 수 있는데, 그 경우도 문제의 규칙대로 "이름순 첫 파일"이 답이다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete csidriver -l practice=f04 --ignore-not-found
sudo rm -rf /opt/course/f04
```

</details>

## Task

Document which container runtime, network plugin and storage drivers cluster `k8s-c1`
uses. Write all answer files on `k8s-c1`; read the node-local files on `worker01`.

1. Write each node's name and the container runtime (with version) that the node reports
   to `/opt/course/f04/runtime.txt`, one node per line.
2. On `worker01`, find the `containerRuntimeEndpoint` set in `/var/lib/kubelet/config.yaml`
   and write its value to `/opt/course/f04/endpoint.txt`.
3. On `worker01`, the container runtime uses the first file in lexical order in
   `/etc/cni/net.d/`. Write that file name and the `type` of the first plugin in it to
   `/opt/course/f04/cni.txt`, in the form `<file> <type>`.
4. Write the names of all CSI drivers registered in the cluster to
   `/opt/course/f04/csi.txt`, one per line.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
