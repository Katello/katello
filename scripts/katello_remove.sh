katello-service stop
kill -9 `ps -aef | grep katello | grep -v $(basename $0) | grep -v grep | awk '{print $2}'`
kill -9 `ps -aef | grep delayed_job | grep -v grep | awk '{print $2}'`

yum erase -y `rpm -qa | grep candlepin` `rpm -qa | grep katello` `rpm -qa | grep ^pulp` `rpm -qa | grep mongo` `rpm -qa | grep postgre` `rpm -qa | grep httpd` `rpm -qa | grep ^mod_` puppet tomcat6 `rpm -qa | grep ^rubygem` ruby rubygems elasticsearch

# config files
rm -rf /etc/pulp/ /etc/candlepin/ /etc/katello/ /usr/share/katello/ /var/lib/puppet/ /var/lib/pgsql/ /var/lib/mongodb/ /var/lib/katello/ /var/lib/pulp/ /etc/httpd/ /etc/tomcat6/ /etc/elasticsearch /var/lib/elasticsearch /usr/share/pulp /var/lib/candlepin

# logs
rm -rf /var/log/katello/ /var/log/tomcat6/ /var/log/pulp/ /var/log/candlepin/ /var/log/httpd/ /var/log/mongodb/

# pulp cert stuff 
rm -rf /etc/pki/pulp/ /etc/pki/content/* /etc/pki/katello /root/ssl-build

# client cert rpms
rm -rf /var/www/html/pub/candlepin-cert*.rpm
