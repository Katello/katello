#!/bin/sh

MY_DIR=`dirname $0`
source $MY_DIR/utils.sh


#test if process $SERVICE is running
#status=`ps aux | grep -v grep | grep  '/usr/share/tomcat6/bin.bootstrap.jar'`
status=`ps aux | grep -v grep | egrep  'tomcat.*bootstrap.jar'`

if [ -n "$status" ]
then
	msgOK "tomcat6 is running"
	exit 0
else
	msgFail "tomcat6 is not running" "start tomcat"
	exit 1
fi

