#!/bin/bash

#name: Reindex search index
#apply: katello headpin
#run: always
#description:
#This steps completely rebuild elasticsearch index from scratch. Due to upgrade of
#the elasticsearch component it is necessary to flush the index before stopping
#it and then reindexing it.

# default configuration values (should be the same as in our sysv init script)
if [ -f /etc/sysconfig/katello ]; then . /etc/sysconfig/katello; fi
KATELLO_HOME=${KATELLO_HOME:-/usr/share/katello}
KATELLO_ENV=${KATELLO_ENV:-production}
KATELLO_PREFIX=${KATELLO_PREFIX:-/katello}

pushd $KATELLO_HOME >/dev/null
RAILS_RELATIVE_URL_ROOT=$KATELLO_PREFIX RAILS_ENV=$KATELLO_ENV /usr/bin/rake reindex --trace 2>&1
ret_code=$?
popd >/dev/null

exit $ret_code
