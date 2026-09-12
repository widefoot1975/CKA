# q14 — CrashLoopBackOff 원인 분석

| 항목 | 내용 |
|---|---|
| 회차 | mock_exam_a |
| 도메인 | Troubleshooting (30%) |
| 배점 | 7 |
| 컨텍스트 | `kubectl config use-context k8s-c1` |
| 목표 시간 | 9분 |
| 결과 | ☐ 정답 ☐ 부분 ☐ 오답 |

## 문제

`app` 네임스페이스의 Deployment `payment` 의 파드가 `CrashLoopBackOff` 를 반복한다.

1. 원인을 찾아 기록한다.
2. 파드가 정상적으로 `Running` 상태를 유지하도록 고친다.
3. 무엇을 바꿨는지, 왜 그게 원인이었는지 한 줄로 정리한다.

## 내 풀이

```bash

```

<details>
<summary><b>모범 풀이</b> — 진단 순서가 답입니다</summary>

```bash
# 1) 상태와 재시작 횟수
kubectl -n app get pods
kubectl -n app describe pod <pod>          # Events + Last State 의 Exit Code

# 2) 죽기 직전 로그 — --previous 가 핵심
kubectl -n app logs <pod> --previous
kubectl -n app logs <pod> -c <container> --previous
```

**Exit Code로 원인을 좁힙니다.**

| Exit Code / 증상 | 의미 | 흔한 원인 |
|---|---|---|
| 0 인데 재시작 | 프로세스가 정상 종료 | 포그라운드 프로세스가 없음 (`command` 가 바로 끝남) |
| 1 / 2 | 애플리케이션 오류 | 설정 누락, 필수 env 없음 |
| **137** | SIGKILL | **메모리 limit 초과 (OOMKilled)** |
| 143 | SIGTERM | 정상 종료 신호 |
| **127** | command not found | 이미지에 없는 명령을 `command` 로 지정 |

```bash
# OOMKilled 인지 확인
kubectl -n app get pod <pod> -o jsonpath='{.status.containerStatuses[0].lastState.terminated.reason}'; echo
```

**조치 예시**

```bash
# (a) 메모리 부족이면 limit 상향
kubectl -n app set resources deploy payment \
  --limits=memory=512Mi --requests=memory=256Mi

# (b) 필수 env 누락이면 추가
kubectl -n app set env deploy payment DB_HOST=postgres

# (c) liveness probe 가 너무 빡빡해 죽는 경우 — describe 의 Events 에
#     "Liveness probe failed" 가 보이면 initialDelaySeconds 를 늘림
kubectl -n app edit deploy payment
```

**CrashLoopBackOff 는 원인이 아니라 결과**입니다. "재시작을 반복하고 있다"는 상태일 뿐이라, `--previous` 로그와 Exit Code를 보지 않으면 아무것도 알 수 없습니다.

</details>

## 검증

```bash
kubectl -n app get pods                   # Running, RESTARTS 가 더 늘지 않음
kubectl -n app rollout status deploy/payment
sleep 60 && kubectl -n app get pods       # 1분 뒤에도 안정적인지
kubectl -n app logs deploy/payment | tail -20
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `kubectl logs --previous` 없이는 죽은 컨테이너의 로그를 볼 수 없습니다.
- **헷갈리는 지점**: `ImagePullBackOff` 와 `CrashLoopBackOff` 는 완전히 다릅니다. 전자는 이미지를 못 받는 것(태그·레지스트리·시크릿), 후자는 받아서 실행했는데 죽는 것.

## 참고 문서

- 검색어: `debug running pods`
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
