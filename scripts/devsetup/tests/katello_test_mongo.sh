#!/bin/sh

MY_DIR=`dirname $0`
source $MY_DIR/utils.sh


#try to connect and disconnect, check error output
status=`echo 'exit' | mongo 2>&1 >/dev/null`

if [ -z "$status" ]
then
	msgOK "mongo"
	exit 0
else
	msgFail "can't connect to mongo"
	exit 1
fi
