#!/bin/bash

if [ -z $1 ]; then
  echo 'Format: ./rename.sh [game]'
  exit 0 
fi
game=$1

cd $game
mkdir train test
mv 000* train  # NEED CHANGE!
mv 001* test  # NEED CHANGE!

for i in {0..2}  # NEED CHANGE!
do
  mv "test/001$i" "test/000$i"  # NEED CHANGE!
done
