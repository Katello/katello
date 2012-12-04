#!/bin/bash

#name: Start Apache httpd service
#apply: katello headpin
#run: always
#description:
#Start the service

/usr/sbin/service-wait httpd start
