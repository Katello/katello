#!/bin/bash

#name: Migrate MongoDB database
#apply: katello
#run: always
#description:
#This steps calls pulp-migrate tool to migrate Pulp database schema
#to the most recent version.

/usr/bin/pulp-manage-db
