#!/bin/bash
cd src/

touch config/katello.yml
bundle install --without checking:devboost:optional:debugging --quiet

echo ""
echo "********* Headpin RSPEC Unit Tests ****************"
echo "common:" > config/katello.yml
echo "  app_mode: headpin" >> config/katello.yml

psql -c "CREATE USER katellouser WITH PASSWORD 'katellopw';" -U postgres
psql -c "ALTER ROLE katellouser WITH CREATEDB" -U postgres
psql -c "CREATE DATABASE katelloschema OWNER katellouser;" -U postgres

RAILS_ENV=test bundle exec rake db:drop
RAILS_ENV=test bundle exec rake db:create
bundle exec rake db:test:load > /dev/null
bundle exec rspec ./spec --tag '~katello'
if [ $? -ne 0 ]
then
  exit 1
fi