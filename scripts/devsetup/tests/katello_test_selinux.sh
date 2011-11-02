#!/bin/sh

MY_DIR=`dirname $0`
source $MY_DIR/utils.sh


#test status of SELinux
status=`sestatus | egrep -i "Current mode.*permissive|selinux status.*disabled"`

if [ -n "$status" ]
then
	msgOK "SELinux is disabled or permissive"
	exit 0
else
	msgFail "SELinux is enabled" "disable SELinux or set it to permissive mode"
	exit 1
fi
