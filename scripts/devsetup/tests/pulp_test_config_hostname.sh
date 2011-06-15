#!/bin/sh

MY_DIR=`dirname $0`
source $MY_DIR/utils.sh


#test if file /etc/pulp/client.conf contains full hostname 

HOSTNAME=`hostname`

HOSTNAME_LINE=`cat /etc/pulp/client.conf 2> /dev/null | grep '^host'`
CONFIG_HOSTNAME=${HOSTNAME_LINE#*=}


if [ -z $CONFIG_HOSTNAME ]
then
	#/etc/pulp/client.conf doesn't exist
	msgFail "/etc/pulp/client.conf doesn't exist"
	exit 1
fi

if [ $HOSTNAME == $CONFIG_HOSTNAME ]
then
    msgOK '/etc/pulp/client.conf contains correct hostname'
    exit 0
else
    msgFail 'hostname in /etc/pulp/client.conf is incorrect' 'set it to '$HOSTNAME
    exit 1
fi


