#!/bin/bash

#name: Start Apache tomcat service
#apply: katello headpin
#run: always
#description:
#Start the service

if [ -x /etc/init.d/tomcat -o -x /lib/systemd/system/tomcat.service ]; then
  service-wait tomcat start
  RET=$?
elif [ -x /etc/init.d/tomcat6 -o -x /lib/systemd/system/tomcat6.service ]; then
  service-wait tomcat6 start
  RET=$?
else
  echo "Unknown Tomcat version!"; RET=1
fi

exit $RET
