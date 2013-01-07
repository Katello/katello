#!/bin/bash

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
cp -f config/katello.template.yml config/katello.yml
sudo bundle install
rake parallel:drop
rake parallel:create
rake parallel:prepare
rake hudson:spec SPEC_OPTS="-p" --trace
