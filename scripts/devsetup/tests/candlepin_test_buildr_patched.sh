#!/bin/sh

MY_DIR=`dirname $0`
source $MY_DIR/utils.sh


#test if buildr file is patched
line=`sed -n '10p' /usr/bin/buildr 2> /dev/null`

if [ "$line" == "gem 'rspec', '1.3.1'" ]
then
	msgOK "file /usr/bin/buildr patched"
	exit 0
else
	msgFail "file /usr/bin/buildr is not patched" "see https://fedorahosted.org/candlepin/wiki/Deployment"
	exit 1
fi





