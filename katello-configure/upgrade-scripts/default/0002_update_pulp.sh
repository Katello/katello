#!/bin/bash

#name: Update Pulp MongoDB database
#apply: katello
#description:
#Actions that need to be taken to upgrade Pulp subsystem

/usr/sbin/service-wait mongod start
/bin/sleep 10s
/usr/bin/pulp-manage-db

exit 0
