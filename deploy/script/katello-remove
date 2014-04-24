#!/bin/bash

echo ""
echo "WARNING: This script will erase many packages and config files."
echo "Important packages such as the following will be removed:"
echo ""
echo "  * elasticsearch"
echo "  * httpd (apache)"
echo "  * mongodb"
echo "  * tomcat6"
echo "  * puppet"
echo "  * ruby"
echo "  * rubygems"
echo "  * All Katello and Foreman Packages"
echo ""
echo "Once these packages and configuration files are removed there is no going back."
echo "If you use this system for anything other than Katello and Foreman you probably"
echo "do not want to execute this script."
echo ""
read -p "Read the source for a list of what is removed.  Are you sure(Y/N)? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "** cancelled **"
    exit 1
fi

echo ""
echo "ARE YOU SURE?: This script peramently deletes data and configuration."
read -p "Read the source for a list of what is removed.  Type [remove] to continue? " -r
echo    # (optional) move to a new line
if [[ ! $REPLY = remove ]]
then
    echo "** cancelled **"
    exit 1
fi

katello-service stop
kill -9 `ps -aef | grep katello | grep -v $(basename $0) | grep -v grep | awk '{print $2}'`
kill -9 `ps -aef | grep delayed_job | grep -v grep | awk '{print $2}'`

yum erase -y `rpm -qa | grep puppetlabs-release` `rpm -qa | grep foreman-release` `rpm -qa | grep foreman-client` `rpm -qa | grep foreman-proxy` `rpm -qa | grep candlepin` `rpm -qa | grep katello` `rpm -qa | grep ^pulp` `rpm -qa | grep ^python-pulp`  `rpm -qa | grep ^pulp-` `rpm -qa | grep mongo` `rpm -qa | grep postgre` `rpm -qa | grep ^mod_` `rpm -qa | grep ^rubygem` `rpm -qa | grep ^ruby193` `rpm -qa | grep ^foreman` ruby rubygems elasticsearch httpd puppet tomcat tomcat6 

# config files
rm -rf /etc/pulp/ /etc/candlepin/ /etc/katello/ /usr/share/foreman /usr/share/katello/ /var/lib/puppet/ /var/lib/pgsql/ /var/lib/mongodb/ /var/lib/katello/ /var/lib/pulp/ /etc/httpd/ /etc/tomcat6/ /etc/elasticsearch /var/lib/elasticsearch /usr/share/pulp /var/lib/candlepin /etc/foreman /var/lib/foreman /etc/tomcat /etc/katello-installer /etc/foreman-proxy/ /etc/puppet/environments /etc/pki/katello-certs-tools


# logs
rm -rf /var/log/katello/ /var/log/tomcat6/ /var/log/pulp/ /var/log/candlepin/ /var/log/httpd/ /var/log/mongodb/ /var/log/foreman /etc/tomcat /var/log/foreman-proxy

# pulp cert stuff 
rm -rf /etc/pki/pulp/ /etc/pki/content/* /etc/pki/katello /root/ssl-build /etc/pki/tls/certs/katello-node.crt /etc/pki/tls/private/katello-node.key /etc/pki/tls/certs/pulp_consumers_ca.crt /etc/pki/tls/certs/pulp_ssl_cert.crt

# client cert rpms
rm -rf /var/www/html/pub/katello-ca*.rpm

