#!/bin/sh

eval_simple() {
  acc=$1
  shift
  pass1=""

  while [ $# -ge 2 ]; do
    op=$1
    num=$2
    shift 2
    case "$op" in
      x) acc=$(awk "BEGIN {printf \"%.10g\", $acc * $num}") ;;
      /) acc=$(awk "BEGIN {printf \"%.10g\", $acc / $num}") ;;
      +|-) pass1="$pass1 $acc $op"; acc=$num ;;
      *) echo "Unsupported operator: $op" >&2; exit 1 ;;
    esac
  done
  pass1="$pass1 $acc"

  set -- $pass1
  result=$1
  shift

  while [ $# -ge 2 ]; do
    op=$1
    num=$2
    shift 2
    case "$op" in
      +) result=$(awk "BEGIN {printf \"%.10g\", $result + $num}") ;;
      -) result=$(awk "BEGIN {printf \"%.10g\", $result - $num}") ;;
    esac
  done

  echo $result
}

tokenize() {
  echo "$*" | sed 's/(/ ( /g; s/)/ ) /g; s/+/ + /g; s/-/ - /g; s/x/ x /g; s/\// \/ /g' | tr -s ' '
}

validate() {
  open=0
  expect="number"

  for t in $@; do
    case "$t" in
      '(')
        if [ "$expect" != "number" ]; then
          echo "Error: unexpected '(' (expected operator)" >&2; exit 1
        fi
        open=$((open + 1))
        ;;
      ')')
        if [ "$expect" != "operator" ]; then
          echo "Error: unexpected ')' (expected number)" >&2; exit 1
        fi
        open=$((open - 1))
        if [ $open -lt 0 ]; then
          echo "Error: unmatched ')'" >&2; exit 1
        fi
        ;;
      +|-|x|/)
        if [ "$expect" != "operator" ]; then
          echo "Error: unexpected operator '$t' (expected number)" >&2; exit 1
        fi
        expect="number"
        ;;
      *)
        case "$t" in
          ''|*[!0-9.]*) echo "Error: invalid token '$t'" >&2; exit 1 ;;
        esac
        if [ "$expect" != "number" ]; then
          echo "Error: unexpected number '$t' (expected operator)" >&2; exit 1
        fi
        expect="operator"
        ;;
    esac
  done

  if [ $open -ne 0 ]; then
    echo "Error: unmatched '(' ($open unclosed)" >&2; exit 1
  fi

  if [ "$expect" != "operator" ]; then
    echo "Error: expression ends with an operator" >&2; exit 1
  fi
}

if [ $# -lt 1 ]; then
  echo "Usage: $0 \"<expression>\""
  echo "  Operators: +, -, x, /"
  echo "  Grouping: ( and )"
  echo "  Example: $0 \"(2+3)x4\""
  exit 1
fi

tokens=$(tokenize "$*")
validate $tokens

while echo "$tokens" | grep -qF '('; do
  set -- $tokens
  last_open=0
  pos=0
  while [ $# -gt 0 ]; do
    pos=$((pos + 1))
    if [ "$1" = "(" ]; then
      last_open=$pos
    fi
    shift
  done

  set -- $tokens
  before=""
  inner=""
  after=""
  pos=0
  state="before"

  while [ $# -gt 0 ]; do
    pos=$((pos + 1))
    if [ "$state" = "before" ]; then
      if [ $pos -eq $last_open ]; then
        state="inner"
      else
        before="$before $1"
      fi
    elif [ "$state" = "inner" ]; then
      if [ "$1" = ")" ]; then
        state="after"
      else
        inner="$inner $1"
      fi
    else
      after="$after $1"
    fi
    shift
  done

  inner_result=$(eval_simple $inner)
  tokens="$before $inner_result $after"
done

eval_simple $tokens
