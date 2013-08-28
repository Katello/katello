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

bundle exec rake minitest || exit 1

echo ""
cd engines/fort/
RAILS_ENV='test' bundle exec rake test || exit 1
cd ../..
echo "Fort tests complete"

echo ""
echo "********* Source Code Lint Tests ****************"
RAILS_ENV='build' ruby -Itest test/source_code_test.rb || exit 1
echo "Ruby code checked."

echo ""
echo "********* Rubocop Lint Test ****************"
bundle exec rubocop || exit 1
echo "Ruby code passed rubocop check."

echo ""
echo "********* JSHint Javascript Check ****************"
RAILS_ENV=development bundle exec rake jshint || exit 1
echo "Javascript code checked."

echo ""
echo "********* Testing Asset Precompile ****************"
bundle exec rake assets:precompile || exit 1
echo "Asset precompile works."
