#!/bin/bash

cd src/
echo "\n"
echo "********* Stylesheet Compilation Test  ***************"
echo "RUNNING: RAILS_ENV=development bundle exec compass compile"
if ruby -v | grep -v 1.9.3; then
  RAILS_ENV=development bundle exec compass compile
  if [ $? -ne 0 ]
  then
    exit 1
  fi
fi

echo ""
echo "********* RSPEC Unit Tests ****************"
psql -c "CREATE USER katello WITH PASSWORD 'katello';" -U postgres
psql -c "ALTER ROLE katello WITH CREATEDB" -U postgres
psql -c "CREATE DATABASE katello_test OWNER katello;" -U postgres
bundle exec rake parallel:create VERBOSE=false
bundle exec rake parallel:migrate VERBOSE=alse
bundle exec rake ptest:spec
