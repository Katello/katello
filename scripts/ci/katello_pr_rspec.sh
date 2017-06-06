#!/bin/bash
cd src/

touch config/katello.yml
bundle install --without checking:devboost:optional:debugging --quiet

echo ""
echo "********* Katello RSPEC Unit Tests ****************"

psql -c "CREATE USER katellouser WITH PASSWORD 'katellopw';" -U postgres
psql -c "ALTER ROLE katellouser WITH CREATEDB" -U postgres
psql -c "CREATE DATABASE katelloschema OWNER katellouser;" -U postgres

RAILS_ENV=test bundle exec rake db:create
bundle exec rake db:test:load > /dev/null
bundle exec rspec ./spec --tag '~headpin'
if [ $? -ne 0 ]
then
  exit 1
fi
