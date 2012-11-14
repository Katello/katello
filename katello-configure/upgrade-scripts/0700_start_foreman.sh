#!/bin/bash

#name: Start foreman service
#apply: katello
#run: always
#description:
#Start the service

/usr/sbin/service-wait foreman start
