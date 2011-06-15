#!/bin/sh

MY_DIR=`dirname $0`
source $MY_DIR/utils.sh

#check database
DBNAME=candlepin
db=`psql --list -U postgres 2> /dev/null | grep $DBNAME | awk '{print $1}'`


if [ "$db" == $DBNAME ]
then
	msgOK "database $DBNAME exists"
	exit 0
else
	msgFail "database $DBNAME does not exist" "create candlepin database, see https://fedorahosted.org/candlepin/wiki/Deployment"
	exit 1
fi

