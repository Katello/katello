#!/bin/bash

echo ""
echo "********* Source Code Lint Tests ****************"
RAILS_ENV='build' ruby -Itest test/source_code_test.rb
if [ $? -ne 0 ]
then
  exit 1
fi
echo "Ruby code checked."

echo ""
echo "********* JSHint Javascript Check ****************"
RAILS_ENV=development bundle exec rake jshint
if [ $? -ne 0 ]
then
  exit 1
fi
echo "Javascript code checked."

