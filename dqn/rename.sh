#!/bin/bash

if [ -z $1 ]; then
  echo 'Format: ./rename.sh [game]'
  exit 0 
fi
game=$1

for i in {00..20}; do
  mv "./$game/test/01$i" "./$game/test/00$i"
done
