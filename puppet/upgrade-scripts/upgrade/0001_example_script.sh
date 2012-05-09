#!/bin/bash

#name: Example script 1
#apply: katello headpin
#description: Empty bash script

# default configuration values (should be the same as in our sysv init script)
if [ -f /etc/sysconfig/katello ]; then . /etc/sysconfig/katello; fi
KATELLO_HOME=${KATELLO_HOME:-/usr/share/katello}
KATELLO_PREFIX=${KATELLO_PREFIX:-/katello}

# Example of checking for an upgrade to apply only to katello, such as pulp upgrade
if [ "$KATELLO_PREFIX" = "/katello" ] || [ "$KATELLO_PREFIX" = "/cfse" ]; then
  echo "Example upgrade"
fi

exit 0