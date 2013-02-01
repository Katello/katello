#!/bin/bash

#name: Configure and upgrade katello config files
#apply: katello headpin
#run: always
#description:
#This steps calls katello-configure --katello-configuration-files-only to configure and upgrade old
#Katello configuration files. Configuration files are replaced from erb templates
#which are distributed as part of katello-configure package. Make sure you
#have backup of all configuration files if you made any changes in it.

katello-configure -b --answer-file=/etc/katello/katello-configure.conf --katello-configuration-files-only

