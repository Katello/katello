#!/bin/bash

#name: Reconfigure with katello-configure
#apply: katello headpin
#description:
#Calls katello-configure to re-deploy configuration and restart services

# do it twice - in rare cases configuration file changes needs two runs
katello-configure -b --answer-file=/etc/katello/katello-configure.conf && \
  katello-configure -b --answer-file=/etc/katello/katello-configure.conf
