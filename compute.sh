#!/bin/sh

# Evaluate expression with operator precedence (no parentheses)
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

# Tokenize: insert spaces around operators and parentheses
tokenize() {
  echo "$*" | sed 's/(/ ( /g; s/)/ ) /g; s/+/ + /g; s/-/ - /g; s/x/ x /g; s/\// \/ /g' | tr -s ' '
}

# Main
if [ $# -lt 1 ]; then
  echo "Usage: $0 \"<expression>\""
  echo "  Operators: +, -, x, /"
  echo "  Grouping: ( and )"
  echo "  Example: $0 \"(2+3)x4\""
  exit 1
fi

tokens=$(tokenize "$*")

# Validate matching parentheses
open=0
for t in $tokens; do
  case "$t" in
    '(') open=$((open + 1)) ;;
    ')') open=$((open - 1)) ;;
  esac
  if [ $open -lt 0 ]; then
    echo "Error: unmatched ')'" >&2
    exit 1
  fi
done

if [ $open -ne 0 ]; then
  echo "Error: unmatched '(' ($open unclosed)" >&2
  exit 1
fi

# Validate token pattern: num op num op num ...
# (ignore parentheses for this check — validate the flat structure)
check_tokens=$(echo "$tokens" | sed 's/(//g; s/)//g' | tr -s ' ')
set -- $check_tokens
pos=1
for t in $@; do
  if [ $((pos % 2)) -eq 1 ]; then
    # Expect a number
    case "$t" in
      ''|*[!0-9.]*) echo "Error: expected a number at position $pos, got '$t'" >&2; exit 1 ;;
    esac
  else
    # Expect an operator
    case "$t" in
      +|-|x|/) ;;
      *) echo "Error: expected an operator at position $pos, got '$t'" >&2; exit 1 ;;
    esac
  fi
  pos=$((pos + 1))
done

# Must end on a number (odd count)
if [ $(($# % 2)) -ne 1 ]; then
  echo "Error: expression ends with an operator" >&2
  exit 1
fi


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
