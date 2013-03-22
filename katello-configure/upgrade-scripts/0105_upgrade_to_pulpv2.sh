#!/bin/bash

#name: Upgrade from pulpv1 to pulpv2 
#apply: katello
#run: once
#description:
#This steps calls pulp-migrate tool to migrate Pulp database schema
#to the most recent version.

if [ -f /etc/sysconfig/katello ]; then . /etc/sysconfig/katello; fi

pulp-v1-upgrade --backup-v1-db || exit 1
/usr/bin/pulp-manage-db || exit 1

