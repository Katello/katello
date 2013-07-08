#!/bin/bash

echo ""
echo "********* Katello RSPEC Unit Tests ****************"

psql -c "CREATE USER katellouser WITH PASSWORD 'katellopw';" -U postgres
psql -c "ALTER ROLE katellouser WITH CREATEDB" -U postgres
psql -c "CREATE DATABASE katelloschema OWNER katellouser;" -U postgres

RAILS_ENV=test bundle exec rake db:create

# SCHEMA: return to schema usage after FKs fixed
# bundle exec rake db:test:load > /dev/null
RAILS_ENV=test bundle exec rake db:migrate > /dev/null
bundle exec rspec ./spec --tag '~headpin'
if [ $? -ne 0 ]
then
  exit 1
fi
