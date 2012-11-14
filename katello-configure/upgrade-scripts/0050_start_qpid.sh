#!/bin/bash

#name: Start qpidd service
#apply: katello
#run: always
#description:
#Start the service

/usr/sbin/service-wait qpidd start
