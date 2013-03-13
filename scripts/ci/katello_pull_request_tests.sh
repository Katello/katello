#!/bin/bash

cd src/
echo ""
echo "********* Stylesheet Compilation Test  ***************"
echo "RUNNING: RAILS_ENV=development bundle exec compass compile"
RAILS_ENV=development bundle exec compass compile
if [ $? -ne 0 ]
then
  exit 1
fi

echo ""
echo "********* Ruby Lint Test  ***************"
echo "RUNNING: ./script/ruby-linter"
./script/ruby-linter
if [ $? -ne 0 ]
then
  exit 1
fi

echo ""
echo "********* Katello RSPEC Unit Tests ****************"
psql -c "CREATE USER katello WITH PASSWORD 'katello';" -U postgres
psql -c "ALTER ROLE katello WITH CREATEDB" -U postgres
psql -c "CREATE DATABASE katello_test OWNER katello;" -U postgres

# reenable when parallel tests are fixed
#   bundle exec rake parallel:create VERBOSE=false
#   bundle exec rake parallel:load_schema VERBOSE=false > /dev/null
#   bundle exec rake ptest:spec

RAILS_ENV=test bundle exec rake db:create
bundle exec rake db:test:load > /dev/null
bundle exec rspec ./spec --tag '~headpin'
if [ $? -ne 0 ]
then
  exit 1
fi

echo ""
echo "********* Minitest Model and Glue Tests ****************"
bundle exec rake minitest
if [ $? -ne 0 ]
then
  exit 1
fi

cd ../cli

echo ""
echo "********* Python CLI Unit Tests ***************"
echo "RUNNING: make test"
make test || exit 1

echo ""
echo "********* Running Pylint ************************"
echo "RUNNING: PYTHONPATH=src/ pylint --rcfile=./etc/spacewalk-pylint.rc --additional-builtins=_ katello"
PYTHONPATH=src/ pylint --rcfile=./etc/spacewalk-pylint.rc --additional-builtins=_ katello || exit 1

cd ../src

echo ""
echo "********* Headpin RSPEC Unit Tests ****************"
echo "common:" > config/katello.yml
echo "  app_mode: headpin" >> config/katello.yml

# reenable when parallel tests are fixed
#   bundle exec rake parallel:prepare VERBOSE=false
#   bundle exec rake ptest:spec

bundle exec rspec ./spec --tag '~katello'
if [ $? -ne 0 ]
then
  exit 1
fi
