#!/bin/bash

echo ""
echo "********* JSHint Javascript Check ****************"
RAILS_ENV=development bundle exec rake jshint
if [ $? -ne 0 ]
then
  exit 1
fi
echo "Javascript code checked."

