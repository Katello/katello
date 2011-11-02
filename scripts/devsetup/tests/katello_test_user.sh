#!/bin/sh

MY_DIR=`dirname $0`
source $MY_DIR/utils.sh


#test if the script is running as root
if [[ $EUID -ne 0 ]]; then
	msgOK "the script is not running as root"
else
	msgWarn "the script is running as root"
fi

exit 0
