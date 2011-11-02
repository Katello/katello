#!/bin/sh

MY_DIR=`dirname $0`
source $MY_DIR/utils.sh


status=0

#test if file /etc/pulp/client.conf exists
if [ -f /etc/pulp/client.conf ]
then
	msgOK 'file /etc/pulp/client.conf exists'
else
	msgFail 'missing file /etc/pulp/client.conf'
	status=1
fi

#test if file /etc/pulp/pulp.conf exists
if [ -f /etc/pulp/pulp.conf ]
then
	msgOK 'file /etc/pulp/pulp.conf exists'
else
	msgFail 'missing file /etc/pulp/pulp.conf'
	status=1
fi

exit $status
