#!/bin/sh

MY_DIR=`dirname $0`
source $MY_DIR/utils.sh

#test if file /etc/candlepin/candlepin.conf exists
if [ -f /etc/candlepin/candlepin.conf ]
then
	msgOK 'file /etc/candlepin/candlepin.conf exists'
	exit 0
else
	msgFail 'missing file /etc/candlepin/candlepin.conf'
	exit 1
fi
