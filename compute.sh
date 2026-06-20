#!/bin/sh

if [ $# -ne 3 ]; then
  echo "Usage: $0 <num1> <+|-> <num2>"
  exit 1
fi

case "$2" in
  +) echo $(($1 + $3)) ;;
  -) echo $(($1 - $3)) ;;
  *) echo "Unsupported operator: $2"; exit 1 ;;
esac
