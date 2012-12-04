#!/bin/bash

#name: Start katello service
#apply: katello headpin
#run: always
#description:
#Start the service

/usr/sbin/service-wait katello start
