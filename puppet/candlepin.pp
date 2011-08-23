#
# Copyright (c) 2009 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2+. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.

 
 
#
# Creates and installs the Candlepin server. This
# will probably only work against a clean install
#
# To run this against a fedora machine, do the following
# yum install puppet
# puppet candlepin.pp

define line($file, $line, $ensure = 'present') {
    case $ensure {
        default : { err ( "unknown ensure value ${ensure}" ) }
        present: {
            exec { "/bin/echo '${line}' >> '${file}'":
                unless => "/bin/grep -qFx '${line}' '${file}'"
            }
        }
        absent: {
            exec { "/bin/grep -vFx '${line}' '${file}' | /usr/bin/tee '${file}' > /dev/null 2>&1":
              onlyif => "/bin/grep -qFx '${line}' '${file}'"
            }

            # Use this resource instead if your platform's grep doesn't support -vFx;
            # note that this command has been known to have problems with lines containing quotes.
            # exec { "/usr/bin/perl -ni -e 'print unless /^\\Q${line}\\E\$/' '${file}'":
            #     onlyif => "/bin/grep -qFx '${line}' '${file}'"
            # }
        }
    }
}


#
# Get the candlepin repo and install it
#
exec {"getRepoFile":
        command => "wget http://repos.fedorapeople.org/repos/candlepin/candlepin/fedora-candlepin.repo",
        creates => "/etc/yum.repos.d/fedora-candlepin.repo",
        cwd => "/etc/yum.repos.d",
        path => "/usr/bin"
}

file {"/etc/yum.repos.d/fedora-candlepin.repo":
}

package {"candlepin-tomcat6":
    ensure => "installed",
        require => Exec["getRepoFile"]
}

#
# Set up Postrges
#
package { [postgresql, ruby-postgres, postgresql-server]: 
    ensure => installed, 
}

exec {"initdb":
        command => "service postgresql initdb",
        creates => "/var/lib/pgsql/data/pg_hba.conf",
        path => "/sbin",
        subscribe => [Package[postgresql-server], Package[postgresql]]            
}

file {"/var/lib/pgsql/data/pg_hba.conf":
}

augeas {"pg_hba.conf":
    context => "/files/var/lib/pgsql/data/pg_hba.conf",
    changes => ["set 1/method trust","set 2/method trust"],
    require => [File["/var/lib/pgsql/data/pg_hba.conf"], Exec["initdb"]]
}

service {postgresql:
    ensure => running,
    enable => true,
    hasstatus => true,
    require => Augeas["pg_hba.conf"]
}

exec {"CandlepinDB":
    command => "/usr/bin/createuser -dls candlepin",
    user => "postgres",
    unless => "/usr/bin/psql -l | grep 'candlepin *|'",
    require => Service["postgresql"],
}

#
# Now configure Candlepin
#

line {"katellomodule":
    line => "module.config.katello=org.fedoraproject.candlepin.katello.KatelloModule",
    file => "/etc/candlepin/candlepin.conf",
    require => Package["candlepin-tomcat6"]
}

exec {"cpsetup":
    command => "/usr/share/candlepin/cpsetup",
    require => [Exec["CandlepinDB"],Line[katellomodule]]
}

notify {"testing":
    message => "Verify install with curl -k -u admin:admin https://localhost:8443/candlepin/status",
    require => Exec["cpsetup"]
}
