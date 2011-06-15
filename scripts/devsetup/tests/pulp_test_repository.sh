#!/bin/sh

MY_DIR=`dirname $0`
source $MY_DIR/utils.sh




#test if repository fedora-pulp is installed
if [ "`yum repolist | grep '^fedora-pulp '`" ]
then 
	msgOK "repository fedora-pulp exist"
	exit 0
else 
	msgFail "repository fedora-pulp missing" "see https://fedorahosted.org/pulp/wiki/UGInstallation"
	exit 1
fi
