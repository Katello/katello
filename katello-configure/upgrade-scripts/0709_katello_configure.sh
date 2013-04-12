#!/bin/bash

#name: Reconfigure with katello-configure
#apply: katello headpin
#run: always
#description:
#This steps calls katello-configure twice to re-deploy configuration
#and restart services. Configuration files are replaced from erb templates
#which are distributed as part of katello-configure package. Make sure you
#have backup of all configuration files if you made any changes in it.

katello-configure -b --answer-file=/etc/katello/katello-configure.conf &> /dev/null
exit 0 
