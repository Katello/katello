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
echo "********* RSPEC Unit Tests ****************"
psql -c "CREATE USER katello WITH PASSWORD 'katello';" -U postgres
psql -c "ALTER ROLE katello WITH CREATEDB" -U postgres
psql -c "CREATE DATABASE katello_test OWNER katello;" -U postgres
bundle exec rake parallel:create VERBOSE=false
bundle exec rake parallel:migrate VERBOSE=false
bundle exec rake ptest:spec
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
cd cli/
echo "RUNNING: make test"
make test
if [ $? -ne 0 ]
then
  exit 1
fi

echo ""
echo "********* Running Pylint ************************"
echo "RUNNING: PYTHONPATH=src/ pylint --rcfile=./etc/spacewalk-pylint.rc --additional-builtins=_ katello"
PYTHONPATH=src/ pylint --rcfile=./etc/spacewalk-pylint.rc --additional-builtins=_ katello
if [ $? -ne 0 ]
then
  exit 1
fi

cd ../

