class candlepin::service {
  # RHBZ 789288 - wait max. 30 secs until service port is avaiable
  exec { "fix-tomcat-sysvinit":
    path        => "/usr/bin:/bin",
    onlyif      => "grep -q 'RHBZ 789288' /etc/init.d/tomcat6; test $? -ne 0",
    command     => 'sed -i \'sXecho -n "Stopping ${TOMCAT_PROG}: "Xecho -n "Stopping ${TOMCAT_PROG}: "\n# RHBZ 789288 - wait max. 30 secs until service port is avaiable\nfor i in {1..10}; do netstat -ln | grep 8005 >/dev/null \&\& break; sleep 3; doneX\' /etc/init.d/tomcat6'
  }

  service {"tomcat6":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    stop       => 'sleep 10; /sbin/service tomcat6 stop', # workaround: if you run start and stop quickly stop will likely fail (RHBZ 842260)
    require    => [ Exec["fix-tomcat-sysvinit"], Class["candlepin::config"], Class["postgres::service"] ]
  }

  exec { "cpinit":
    # tomcat startup is slow - try multiple times (the initialization service is idempotent)
    command => "/usr/bin/wget --timeout=30 --tries=5 --retry-connrefused -qO- http://localhost:8080/candlepin/admin/init >${katello::params::configure_log_base}/cpinit.log 2>&1 && touch /var/lib/katello/cpinit_done",
    require => [ Service["tomcat6"], File["${katello::params::configure_log_base}"] ],
    creates => "/var/lib/katello/cpinit_done",
    before  => Class["apache2::service"]
  }
}
