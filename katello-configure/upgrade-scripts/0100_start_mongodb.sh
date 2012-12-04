#!/bin/bash

#name: Start mongod service
#apply: katello
#run: always
#description:
#Start the service

/usr/sbin/service-wait mongod start
