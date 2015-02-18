#!/bin/bash
# :vim:sw=2:ts=2:et:
#
# This file is installed in /usr/share/foreman/script/foreman-debug.d where
# it is picked by foreman-debug reporting tool. This file contains rules for
# both Katello server and Katello proxy (Satellite 6 / Capsule nodes).
#

# error out if called directly
if [ $BASH_SOURCE == $0 ]
then
  echo "This script should not be executed directly, use foreman-debug instead."
  exit 1
fi

# Installer
add_files "/var/log/{katello,capsule,sam}-installer/*"
add_files "/etc/{katello,capsule,sam}-installer/*"
add_cmd "find /root/ssl-build -ls | sort -k 11" "katello_ssl_build_dir"
add_cmd "find /etc/pki -ls | sort -k 11" "katello_pki_dir"

# Katello
add_files "/etc/pulp/server/plugins.d/*"
add_files "/etc/foreman/plugins/katello.yaml"

# Splice
add_files "/var/log/splice/*"
add_files "/etc/splice/*"
add_files "/etc/httpd/conf.d/splice.conf"

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
add_files "/etc/httpd/conf.d/pulp.conf"
add_files "/etc/pulp/server/plugins.conf.d/nodes/distributor/*"

# MongoDB (*)
if [ $NOGENERIC -eq 0 ]; then
  add_files "/var/log/mongodb/*"
  add_files "/var/lib/mongodb/mongodb.log*"
fi

# Qpidd (*)
if [ $NOGENERIC -eq 0 ]; then
  add_files "/etc/qpid/*"
  add_files "/etc/qpidd.conf"
fi

# Gofer
add_files "/etc/gofer"
add_files "/var/log/gofer"

# FreeIPA (*)
if [ $NOGENERIC -eq 0 ]; then
  add_files "/var/log/ipa*-install.log"
  add_files "/var/log/ipaupgrade.log"
  add_files "/var/log/dirsrv/slapd-*/logs/access"
  add_files "/var/log/dirsrv/slapd-*/logs/errors"
  add_files "/etc/dirsrv/slapd-*/dse.ldif"
  add_files "/etc/dirsrv/slapd-*/schema/99user.ldif"
fi

# Legend:
# * - already collected by sosreport tool (skip when -g option was provided)
