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

SERVICES = ["tomcat6",  "elasticsearch", "pulp-server"]
if [ "$KATELLO_PREFIX" = "/headpin" -o "$KATELLO_PREFIX" = "/sam" ]; then
    SERVICES = ["tomcat6",  "elasticsearch"]
fi
for SERVICE in $SERVICES; do 
    service $SERVICE start
done


pushd $KATELLO_HOME >/dev/null
RAILS_RELATIVE_URL_ROOT=$KATELLO_PREFIX RAILS_ENV=$KATELLO_ENV rake db:migrate --trace 2>&1
ret_code=$?
popd >/dev/null

for SERVICE in $SERVICES; do
    service $SERVICE stop
done

exit $ret_code
