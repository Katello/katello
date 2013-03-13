#!/bin/bash

#name: Upgrade from pulpv1 to pulpv2 
#apply: katello
#run: once
#description:
#This steps calls pulp-migrate tool to migrate Pulp database schema
#to the most recent version.

if [ -f /etc/sysconfig/katello ]; then . /etc/sysconfig/katello; fi
KATELLO_HOME=${KATELLO_HOME:-/usr/share/katello}
KATELLO_ENV=${KATELLO_ENV:-production}
KATELLO_PREFIX=${KATELLO_PREFIX:-/katello}


pulp-v1-upgrade --backup-v1-db || exit 1
/usr/bin/pulp-manage-db || exit 1

/usr/sbin/service-wait httpd start
RAILS_RELATIVE_URL_ROOT=$KATELLO_PREFIX RAILS_ENV=$KATELLO_ENV rake regenerate_repo_metadata
/usr/sbin/service-wait httpd stop

