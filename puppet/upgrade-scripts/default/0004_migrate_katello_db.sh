#!/bin/bash

#name: Migrate Katello database
#apply: katello headpin
#description:
#Updates Katello database schema to the latest version

# default configuration values (should be the same as in our sysv init script)
if [ -f /etc/sysconfig/katello ]; then . /etc/sysconfig/katello; fi
KATELLO_HOME=${KATELLO_HOME:-/usr/share/katello}
KATELLO_ENV=${KATELLO_ENV:-production}
KATELLO_PREFIX=${KATELLO_PREFIX:-/katello}

pushd $KATELLO_HOME >/dev/null
RAILS_RELATIVE_URL_ROOT=$KATELLO_PREFIX RAILS_ENV=$KATELLO_ENV rake db:migrate --trace 2>&1
ret_code=$?
popd >/dev/null

exit $ret_code
