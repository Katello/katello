#!/bin/bash

#name: Upgrade from pulpv1 to pulpv2 
#apply: katello
#run: once
#description:
#This steps calls pulp-migrate tool to migrate Pulp database schema
#to the most recent version.
set -e

if [ -f /etc/sysconfig/katello ]; then . /etc/sysconfig/katello; fi

pulp-v1-upgrade --backup-v1-db
/usr/bin/pulp-manage-db

