# q14 — Pods stay Pending because the scheduler is broken · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

새로 만든 파드가 `Pending` 에 머물고 이벤트도 없다. `kubectl -n kube-system get pods` 에서
`kube-scheduler-cp01` 이 `ImagePullBackOff` 로 보인다.

1. `cp01` 에서 kube-scheduler 정적 파드 매니페스트의 무엇이 잘못됐는지 찾는다.
2. 고치기 전에 매니페스트를 `cp01` 의 `/opt/course/d14/kube-scheduler.yaml.bak` 으로 복사해 둔다.
3. kube-scheduler가 kube-apiserver 매니페스트와 같은 이미지 태그를 쓰도록 매니페스트를 고친다.
4. `kube-scheduler-cp01` 이 `Running` 이고, 새 파드 `sched-test`(image `nginx:1.27`, 네임스페이스
   `default`)가 노드에 스케줄되는지 확인한다.

## 모범 풀이

**증상 읽기(k8s-c1).** 스케줄러가 없으면 파드를 심사하는 주체가 없으므로 `Pending` 인데 이벤트가 **하나도**
없습니다. 스케줄러가 살아서 거절했다면 `FailedScheduling` 이벤트가 남습니다.

```bash
kubectl -n kube-system describe pod kube-scheduler-cp01 | grep -E 'Image:|Failed'
#   Image:   registry.k8s.io/kube-scheduler:v1.35.0x
#   Warning  Failed  ...  Failed to pull image "registry.k8s.io/kube-scheduler:v1.35.0x": ... not found
```

**1~3) cp01 — 매니페스트 비교와 수정**

```bash
ssh cp01
sudo -i
grep 'image:' /etc/kubernetes/manifests/kube-scheduler.yaml /etc/kubernetes/manifests/kube-apiserver.yaml
# .../kube-scheduler.yaml:    image: registry.k8s.io/kube-scheduler:v1.35.0x    ← 태그 오타
# .../kube-apiserver.yaml:    image: registry.k8s.io/kube-apiserver:v1.35.0

mkdir -p /opt/course/d14
cp /etc/kubernetes/manifests/kube-scheduler.yaml /opt/course/d14/kube-scheduler.yaml.bak
vi /etc/kubernetes/manifests/kube-scheduler.yaml         # 태그를 apiserver 와 같은 v1.35.0 으로
crictl ps --name kube-scheduler                          # 잠시 뒤 새 컨테이너가 Running
```

(버전 숫자는 예시입니다. 여러분 클러스터의 kube-apiserver 태그에 맞춥니다.)

**정적 파드는 파일이 전부입니다 — 이 문제의 핵심입니다.** kubelet이 `/etc/kubernetes/manifests` 의
파일을 직접 읽어 파드를 띄우므로, 파일을 저장하면 kubelet이 알아서 파드를 다시 만듭니다. `kubectl apply` 도
kubelet 재시작도 필요 없습니다. API에 보이는 `kube-scheduler-cp01` 은 **미러 파드**라서 `kubectl edit` 로
고쳐도 kubelet은 따르지 않습니다.

**백업은 반드시 매니페스트 디렉터리 밖에 둡니다.** kubelet은 확장자와 관계없이 `.` 으로 시작하지 않는
**모든 파일**을 매니페스트로 읽습니다. `kube-scheduler.yaml.bak` 을 같은 디렉터리에 두면 kubelet이 그
파일로도 정적 파드를 만들려 해서 고친 내용과 충돌합니다.

## 검증

```bash
exit; exit                                               # k8s-c1 로 돌아온다
kubectl -n kube-system get pod kube-scheduler-cp01       # 1/1 Running
kubectl run sched-test --image=nginx:1.27
kubectl get pod sched-test -o wide                       # Running, NODE 열이 채워짐
kubectl get pods -A --field-selector=status.phase=Pending   # 밀려 있던 파드도 스케줄되어 비어 간다
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `Pending` + 이벤트 없음 = 스케줄러 문제. 정적 파드는 `/etc/kubernetes/manifests` 의 파일을 고치면 kubelet이 자동으로 다시 만들고, 백업은 그 디렉터리 밖에 둔다.
- **헷갈리는 지점**: kubeadm 클러스터의 kube-apiserver·kube-controller-manager·kube-scheduler 이미지는 보통 같은 태그를 씁니다(`crictl images | grep kube-` 로 노드에 이미 받아 둔 올바른 태그를 확인할 수 있음). `Pending` 에 `FailedScheduling` 이벤트가 있다면 스케줄러는 정상이고 리소스·taint·affinity 같은 조건 문제입니다.

## 참고 문서

- 검색어: `static pods`
- https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/
- https://kubernetes.io/docs/tasks/debug/debug-cluster/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
