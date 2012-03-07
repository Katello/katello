#!/bin/bash
#
# This bootstrap script is deprecated now, see:
# http://fedorahosted.org/katello/wiki/ConsumerBootstrap

if [ -e $1 ]
then
  echo "Usage: `basename $0` <hostname>"
  exit 55
fi

HOSTNAME=$1


##### FIX UP RHSM.CONF #####
cp /etc/rhsm/rhsm.conf /etc/rhsm/rhsm.conf.prebootstrap

# Hostname
sed 's/^hostname =.*/hostname='"$HOSTNAME"'/' /etc/rhsm/rhsm.conf > /etc/rhsm/rhsm.conf.bootstrap1

# Prefix
sed 's/^prefix =.*/prefix =\/katello\/api\//' /etc/rhsm/rhsm.conf.bootstrap1 > /etc/rhsm/rhsm.conf.bootstrap2

# Baseurl
sed 's/^baseurl=.*/baseurl=https:\/\/'"$HOSTNAME"'\/pulp\/repos/' /etc/rhsm/rhsm.conf.bootstrap2 > /etc/rhsm/rhsm.conf.bootstrap3

#Repo_ca_cert
sed 's/^repo_ca_cert =.*/repo_ca_cert = %(ca_cert_dir)scandlepin-local.pem/' /etc/rhsm/rhsm.conf.bootstrap3 > /etc/rhsm/rhsm.conf.bootstrap4

#Ca_cert_dir
sed 's/^ca_cert_dir =.*/ca_cert_dir = \/etc\/rhsm\/ca/' /etc/rhsm/rhsm.conf.bootstrap4 > /etc/rhsm/rhsm.conf.bootstrap5

cp /etc/rhsm/rhsm.conf.bootstrap5 /etc/rhsm/rhsm.conf
rm -f /etc/rhsm/rhsm.conf.bootstrap*


#### GET THE CERTS ####

# wget -q -O /etc/candlepin/certs/candlepin-local.pem http://$HOSTNAME/pub/candlepin-ca.crt
scp  $HOSTNAME:/etc/candlepin/certs/candlepin-ca.crt /etc/rhsm/ca/candlepin-local.pem

echo "Your system is now ready for subscription-manager"
echo " ** Remeber to do a 'subscription-manager clean' before registering"
