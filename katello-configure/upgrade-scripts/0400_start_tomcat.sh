#!/bin/bash

#name: Start Apache tomcat6 service
#apply: katello headpin
#run: always
#description:
#Start the service

/usr/sbin/service-wait tomcat6 start
