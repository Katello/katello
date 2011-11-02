#!/bin/sh

MY_DIR=`dirname $0`
source $MY_DIR/utils.sh



#test if certificate is installed
if [ ! -f /etc/pki/tls/certs/localhost.crt ]
then
	msgFail 'missing file /etc/pki/tls/certs/localhost.crt'
	exit 1
fi

#check hostname in certificate
hostname=`openssl x509 -text -in /etc/pki/tls/certs/localhost.crt | grep Subject | grep -o 'CN=[^/\w]*'`
hostname=${hostname:3}

if [ "$hostname" == `hostname` ]
then
	msgOK "correct ssl certificate installed"
	exit 0
else
	msgFail "check certificate /etc/pki/tls/certs/localhost.crt" "install correct certificate\nsee https://fedorahosted.org/pulp/wiki/UGFAQ#WhydoIgetSSLWrongHosterrorswhenrunningtheclient"
	exit 1
fi

