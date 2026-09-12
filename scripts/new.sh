#!/usr/bin/env bash
# 새 회차 / 문제 폴더를 템플릿에서 생성합니다.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TPL="$ROOT/_template"

usage() {
  cat <<'EOF'
사용법:
  ./scripts/new.sh exam <회차>                      새 회차 폴더
  ./scripts/new.sh q <회차> <문제번호> <주제>        회차 안에 문제 폴더

예시:
  ./scripts/new.sh exam 02          → mock_exam_02
  ./scripts/new.sh exam b           → mock_exam_b
  ./scripts/new.sh q 02 03 network_policy_deny_all
  ./scripts/new.sh q b 04 pv_pvc_static

회차는 숫자(두 자리로 패딩)와 문자(a, b, c) 모두 됩니다.
주제는 스네이크케이스로 씁니다 (공백 대신 _).
EOF
  exit 1
}

[ $# -ge 2 ] || usage

# 회차 이름: 숫자면 두 자리로 패딩(01, 02), 문자면 소문자 그대로(a, b)
exam_name() {
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    printf 'mock_exam_%02d' "$1"
  else
    printf 'mock_exam_%s' "$(echo "$1" | tr '[:upper:]' '[:lower:]')"
  fi
}

case "$1" in
  exam)
    [ $# -eq 2 ] || usage
    exam=$(exam_name "$2")
    dir="$ROOT/$exam"
    [ -d "$dir" ] && { echo "이미 있습니다: $exam"; exit 1; }
    mkdir -p "$dir"
    sed "s/mock_exam_NN/$exam/g" "$TPL/exam_README.md" > "$dir/README.md"
    echo "생성: $exam/README.md"
    echo
    echo "다음: ./scripts/new.sh q ${2} 01 <주제>"
    ;;

  q)
    [ $# -eq 4 ] || usage
    exam=$(exam_name "$2")
    qnum=$(printf '%02d' "$3")
    topic="$4"
    qdir="$ROOT/$exam/q${qnum}_${topic}"

    [ -d "$ROOT/$exam" ] || { echo "회차가 없습니다: $exam  (먼저 ./scripts/new.sh exam $2)"; exit 1; }
    [ -d "$qdir" ] && { echo "이미 있습니다: $exam/q${qnum}_${topic}"; exit 1; }

    mkdir -p "$qdir"
    cp -r "$TPL/question/." "$qdir/"
    mkdir -p "$qdir/manifests" "$qdir/files" "$qdir/setup"
    touch "$qdir/manifests/.gitkeep" "$qdir/files/.gitkeep"

    for f in "$qdir/question.md" "$qdir/solution.md"; do
      sed -i \
        -e "s/mock_exam_NN/$exam/g" \
        -e "s/# qNN — Task title in English/# q${qnum} — ${topic//_/ }/" \
        "$f"
    done

    chmod +x "$qdir/verify.sh" "$qdir/cleanup.sh" "$qdir/setup/setup.sh"

    echo "생성: $exam/q${qnum}_${topic}/"
    find "$qdir" -mindepth 1 | sed "s|$qdir|  .|"
    echo
    echo "다음: $exam/README.md 의 문항 표에 한 줄 추가하세요:"
    echo "  | ${qnum} | <English task title> | <도메인> | <배점> | ☐ | [question](q${qnum}_${topic}/question.md) | [solution](q${qnum}_${topic}/solution.md) |"
    echo
    echo "question.md 는 영문, solution.md 는 한글로 작성합니다."
    ;;

  *) usage ;;
esac
