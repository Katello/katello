#!/bin/bash

#name: Start elasticsearch service
#apply: katello headpin
#run: always
#description:
#Start the service

/usr/sbin/service-wait elasticsearch start
