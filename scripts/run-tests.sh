#!/bin/bash

# cd to root of project
cd ..

# Check JavaScript syntax
jsl --conf scripts/jsl-errors-only.conf 
OUT=$?
if [ $OUT -ge 3 ];then
  echo ""
  echo ""
  echo ""
  echo "SYNTAX ERROR detected in JavaScript files in src/public/javascripts/.  "
  echo "Run jsl --conf scripts/jsl-errors-only.conf to reproduce locally."
  echo ""
  echo ""
  echo ""
  exit 1
fi

# Run unit tests
cd src
sudo bundle install
rake db:migrate:reset --trace 
rake yard hudson:spec SPEC_OPTS="-p" --trace
