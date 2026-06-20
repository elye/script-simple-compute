#!/bin/sh

# Evaluate expression with operator precedence (no parentheses)
eval_simple() {
  # First pass: handle x and /
  acc=$1
  shift
  pass1=""

  while [ $# -ge 2 ]; do
    op=$1
    num=$2
    shift 2
    case "$op" in
      x) acc=$((acc * num)) ;;
      /) acc=$((acc / num)) ;;
      +|-) pass1="$pass1 $acc $op"; acc=$num ;;
      *) echo "Unsupported operator: $op" >&2; exit 1 ;;
    esac
  done
  pass1="$pass1 $acc"

  # Second pass: handle + and -
  set -- $pass1
  result=$1
  shift

  while [ $# -ge 2 ]; do
    op=$1
    num=$2
    shift 2
    case "$op" in
      +) result=$((result + num)) ;;
      -) result=$((result - num)) ;;
    esac
  done

  echo $result
}

# Main: resolve brackets from innermost out, then evaluate
if [ $# -lt 1 ]; then
  echo "Usage: $0 <expression>"
  echo "  Operators: +, -, x, /"
  echo "  Brackets: [ and ]"
  echo "  Example: $0 [ 2 + 3 ] x 4"
  exit 1
fi

tokens="$*"

while echo "$tokens" | grep -qF '['; do
  # Find the last opening bracket
  set -- $tokens
  last_open=0
  pos=0
  while [ $# -gt 0 ]; do
    pos=$((pos + 1))
    if [ "$1" = "[" ]; then
      last_open=$pos
    fi
    shift
  done

  # Split into before, inner (between last '[' and its matching ']'), after
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
      if [ "$1" = "]" ]; then
        state="after"
      else
        inner="$inner $1"
      fi
    else
      after="$after $1"
    fi
    shift
  done

  # Evaluate the inner expression and substitute
  inner_result=$(eval_simple $inner)
  tokens="$before $inner_result $after"
done

# Final evaluation with precedence
eval_simple $tokens
