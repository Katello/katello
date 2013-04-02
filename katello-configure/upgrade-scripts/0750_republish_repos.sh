#!/bin/bash

#name: Republish all repos after upgrading to pulpv2
#apply: katello
#run: once
#description:
#This steps calls rake regenerate_repo_metadata to regenerate repo metadata

if [ -f /etc/sysconfig/katello ]; then . /etc/sysconfig/katello; fi
KATELLO_HOME=${KATELLO_HOME:-/usr/share/katello}
KATELLO_ENV=${KATELLO_ENV:-production}
KATELLO_PREFIX=${KATELLO_PREFIX:-/katello}

pushd $KATELLO_HOME >/dev/null
RAILS_RELATIVE_URL_ROOT=$KATELLO_PREFIX RAILS_ENV=$KATELLO_ENV rake regenerate_repo_metadata
ret_code=$?
popd >/dev/null

exit $?

