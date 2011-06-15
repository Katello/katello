#!/bin/sh

MY_DIR=`dirname $0`
source $MY_DIR/utils.sh

#test if directories /var/cache/tomcat6 and /var/log/tomcat6 have
#write permissions for user tomcat6



status=0

#get permissions, owner and group
perm=`ls -l /var/cache/ | grep tomcat6 | awk '{print $1}'`
owner=`ls -l /var/cache/ | grep tomcat6 | awk '{print $3}'`
group=`ls -l /var/cache/ | grep tomcat6 | awk '{print $4}'`

if [ -z $perm ]
then
	#directory /var/cache/tomcat6 doesn't exist
	echo msgFail "directory /var/cache/tomcat6 doesn't exist"
	status=1
else

	if ([ ${perm:1:3} == "rwx" ] && [ $owner == "tomcat" ]) ||
	   ([ ${perm:4:3} == "rwx" ] && [ $group == "tomcat" ])
	then
		msgOK "directory /var/cache/tomcat6 permissions ($perm)"
	else
		msgFail "directory /var/cache/tomcat6 permissions incorrect ($perm)" "chown tomcat:tomcat <path>, see https://fedorahosted.org/candlepin/wiki/Deployment"
		status=1
	fi

fi



#get permissions, owner and group
perm=`ls -l /var/log/ | grep tomcat6 | awk '{print $1}'`
owner=`ls -l /var/log/ | grep tomcat6 | awk '{print $3}'`
group=`ls -l /var/log/ | grep tomcat6 | awk '{print $4}'`

if [ -z $perm ]
then
	#directory /var/cache/tomcat6 doesn't exist
	msgFail "directory /var/log/tomcat6 doesn't exist"
	status=1
else

	if ([ ${perm:1:3} == "rwx" ] && [ $owner == "tomcat" ]) ||
	   ([ ${perm:4:3} == "rwx" ] && [ $group == "tomcat" ])
	then
		msgOK "directory /var/log/tomcat6 permissions ($perm)"
	else
		msgFail "directory /var/log/tomcat6 permissions incorrect ($perm)" "chown tomcat:tomcat <path>, see https://fedorahosted.org/candlepin/wiki/Deployment"
		status=1
	fi

fi

exit $status


