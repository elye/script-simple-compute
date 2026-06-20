#!/bin/sh

if [ $# -lt 3 ] || [ $(($# % 2)) -ne 1 ]; then
  echo "Usage: $0 <num1> operator <num2> [operator <num3> ...]"
  echo "  Operator can be +, -, x or /"
  exit 1
fi

# First pass: evaluate x and /
args=""
acc=$1
pending_op=""
shift

while [ $# -ge 2 ]; do
  op=$1
  num=$2
  shift 2

  case "$op" in
    x) acc=$((acc * num)) ;;
    /) acc=$((acc / num)) ;;
    +|-) 
      args="$args $acc $op"
      acc=$num
      ;;
    *) echo "Unsupported operator: $op"; exit 1 ;;
  esac
done
args="$args $acc"

# Second pass: evaluate + and -
set -- $args
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
