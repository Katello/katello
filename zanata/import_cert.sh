#!/bin/bash

# This script attempts to find any JREs (1.6 or later) which are installed,
# and then inserts the Red Hat IS CA as a trusted certificate.
# This enables Java clients to access internal Red Hat secure web servers.
#
# Sean Flanigan <sflaniga@redhat.com>

dir=`mktemp -d`
cd $dir
wget --no-check-certificate https://password.corp.redhat.com/cacert.crt

keystores=`rpm -qal 'java-1.[^5]*' | grep '/lib/security/cacerts$'`
#keystores='/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0/jre/lib/security/cacerts'

for keystore in $keystores
do
  jre=${keystore%/lib/security/cacerts}
  keytool=$jre/bin/keytool
  $keytool -import -noprompt -keystore $keystore -storepass changeit -alias 'Red Hat IS CA eng-i18n' -file cacert.crt || echo ignoring error;  
done
