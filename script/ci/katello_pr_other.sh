#!/bin/bash

echo ""
echo "********* Minitest Model and Glue Tests ****************"
psql -c "CREATE USER katellouser WITH PASSWORD 'katellopw';" -U postgres
psql -c "ALTER ROLE katellouser WITH CREATEDB" -U postgres
psql -c "CREATE DATABASE katelloschema OWNER katellouser;" -U postgres

RAILS_ENV=test bundle exec rake db:create

# SCHEMA: return to schema usage after FKs fixed
# bundle exec rake db:test:load > /dev/null
RAILS_ENV=test bundle exec rake db:migrate > /dev/null

bundle exec rake minitest
if [ $? -ne 0 ]
then
  exit 1
fi

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

echo ""
echo "********* Testing Asset Precompile ****************"
bundle exec rake assets:precompile

if [ $? -ne 0 ]
then
  exit 1
fi
echo "Asset precompile works."
