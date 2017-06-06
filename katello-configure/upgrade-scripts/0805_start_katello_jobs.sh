#!/bin/bash

#name: Start katello-jobs service
#apply: katello headpin
#run: always
#description:
#Start the service

/usr/sbin/service-wait katello-jobs start
