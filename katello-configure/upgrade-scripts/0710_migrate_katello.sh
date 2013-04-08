#!/bin/bash

#name: Migrate Katello database
#apply: katello headpin
#run: always
#description:
#This step calls rake db:migrate target to update Katello database schema in the
#postgresql to the latest version.

# default configuration values (should be the same as in our sysv init script)
if [ -f /etc/sysconfig/katello ]; then . /etc/sysconfig/katello; fi
KATELLO_HOME=${KATELLO_HOME:-/usr/share/katello}
KATELLO_ENV=${KATELLO_ENV:-production}
KATELLO_PREFIX=${KATELLO_PREFIX:-/katello}

pushd $KATELLO_HOME >/dev/null
RAILS_RELATIVE_URL_ROOT=$KATELLO_PREFIX RAILS_ENV=$KATELLO_ENV /usr/bin/rake db:migrate --trace 2>&1
RAILS_RELATIVE_URL_ROOT=$KATELLO_PREFIX RAILS_ENV=$KATELLO_ENV /usr/bin/rake reindex --trace 2>&1
ret_code=$?
popd >/dev/null

exit $ret_code
