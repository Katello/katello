#!/bin/bash

# Check JavaScript syntax
jsl --conf scripts/jsl-errors-only.conf 
OUT=$?
if [ $OUT -ge 3 ];then
  echo "SYNTAX ERROR detected in JavaScript files in src/public/javascripts/"
  exit 1
fi

# Run unit tests
cd src
sudo bundle install
rake db:migrate:reset --trace 
rake yard hudson:spec SPEC_OPTS="-p" --trace
