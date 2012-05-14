#!/bin/bash

#name: Migrate Katello database
#apply: katello headpin
#description:
#Updates Katello database schema to the latest version

# default configuration values (should be the same as in our sysv init script)
KATELLO_HOME=${KATELLO_HOME:-/usr/share/katello}
KATELLO_ENV=${KATELLO_ENV:-production}

pushd $KATELLO_HOME >/dev/null
RAILS_ENV=$KATELLO_ENV rake db:migrate --trace 2>&1
ret_code=$?
popd >/dev/null

exit $ret_code
