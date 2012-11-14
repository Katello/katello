#!/bin/bash

#name: Start Apache tomcat service
#apply: katello headpin
#run: always
#description:
#Start the service

if [ -x /lib/systemd/system/tomcat7.service ]; then
  service-wait tomcat7 start
  RET=$?
elif [ -x /etc/init.d/tomcat6 -o -x /lib/systemd/system/tomcat6.service ]; then
  service-wait tomcat6 start
  RET=$?
else
  echo "Unknown Tomcat version!"; RET=1
fi

exit $RET
