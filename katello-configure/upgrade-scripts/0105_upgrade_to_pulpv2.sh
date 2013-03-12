#!/bin/bash

#name: Upgrade from pulpv1 to pulpv2 
#apply: katello
#run: once
#description:
#This steps calls pulp-migrate tool to migrate Pulp database schema
#to the most recent version.

pulp-v1-upgrade --backup-v1-db
/usr/bin/pulp-migrate

/usr/sbin/service-wait httpd start
RAILS_RELATIVE_URL_ROOT=$KATELLO_PREFIX RAILS_ENV=$KATELLO_ENV rake regenerate_repo_metadata
/usr/sbin/service-wait httpd stop

