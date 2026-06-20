#!/bin/sh

if [ $# -lt 3 ] || [ $(($# % 2)) -ne 1 ]; then
  echo "Usage: $0 <num1> operator <num2> [operator <num3> ...]"
  echo "  Operator can be +, -, x or /"
  exit 1
fi

result=$1
shift

while [ $# -ge 2 ]; do
  op=$1
  num=$2
  shift 2

  case "$op" in
    +) result=$((result + num)) ;;
    -) result=$((result - num)) ;;
    x) result=$((result * num)) ;;
    /) result=$((result / num)) ;;
    *) echo "Unsupported operator: $op"; exit 1 ;;
  esac
done

echo $result
