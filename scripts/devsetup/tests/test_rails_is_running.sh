#!/bin/sh

MY_DIR=`dirname $0`
source $MY_DIR/utils.sh



#test if process 'ruby script/rails s' is running
status=` ps aux | grep -v grep | grep  'ruby script/rails s'`

if [ -n "$status" ]
then
	msgOK "rails is running"
	exit 0
else
	msgFail "rails is not running"
	exit 1
fi
