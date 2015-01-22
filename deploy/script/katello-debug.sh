# error out if called directly
if [ $BASH_SOURCE == $0 ]
then
  echo "This script should not be executed directly, use foreman-debug instead."
  exit 1
fi

# General stuff
add_files "/var/log/audit/audit.log"

# Candlepin
add_files "/var/log/candlepin/*"
add_files "/var/log/tomcat6/*"
add_files "/var/log/tomcat/*"
add_files "/etc/candlepin/candlepin.conf"
add_files "/etc/tomcat6/server.xml"
add_files "/etc/tomcat/server.xml"

# Elastic Search
add_files "/var/log/elasticsearch/*"
add_files "/etc/elasticsearch/*"

# Pulp
add_files "/etc/pulp/*.conf"
add_files "/etc/pulp/server/plugins.conf.d/nodes/distributor/*"
add_files "/var/log/mongodb/*"
add_files "/var/lib/mongodb/mongodb.log*"
add_files "/etc/httpd/conf.d/pulp.conf"
add_files "/etc/qpid/qpidd.conf"
add_cmd "cat /var/log/messages | grep pulp"

#Grab the qpid items from syslog
add_cmd "cat /var/log/messages | grep qpidd" "/var/log/qpidd.log"

# Splice
add_files "/var/log/splice/*"
add_files "/etc/splice/*"
add_files "/etc/httpd/conf.d/splice.conf",
add_files "/etc/cron.d/spacewalk-sst-sync"
add_files "/etc/cron.d/splice-sst-sync"

# Katello
add_files "/var/log/katello/*"
add_files "/var/log/katello-installer/*"
add_files "/etc/katello-installer/*"
add_files "/etc/pulp/server/plugins.d/*"
add_cmd "find /root/ssl-build -ls | sort -k 11" "katello_ssl_build_dir"
add_files "/etc/foreman/plugins/katello.yaml"
add_files "/var/lib/pgsql/data/pg_log/*"
