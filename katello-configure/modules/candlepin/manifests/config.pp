class candlepin::config {

  user { 'tomcat':
    ensure => present,
    groups => ['katello'],
    before => Service["tomcat6"]
  }

  postgres::createuser { $candlepin::params::db_user:
    passwd => $candlepin::params::db_pass,
    logfile  => "${katello::params::configure_log_base}/create-postgresql-candlepin-user.log",
    require => [ File["${katello::params::configure_log_base}"] ],
  }

  file { "/etc/candlepin/candlepin.conf":
    content => template("candlepin/etc/candlepin/candlepin.conf.erb"),
    mode    => '600',
    owner   => 'tomcat',
    notify  => Service["tomcat6"];
  "/etc/tomcat6/server.xml":
    content => template("candlepin/etc/tomcat6/server.xml.erb"),
    mode    => '644',
    owner   => 'root',
    group   => 'root',
    notify  => Service["tomcat6"];
  # various tomcat versions had some permission bugs - fix them all
  "/etc/tomcat6":
    mode    => '775';
  "/var/log/tomcat6":
    mode    => '775',
    owner   => 'root',
    group   => 'tomcat';
  "/var/lib/tomcat6":
    mode    => '775',
    owner   => 'tomcat',
    group   => 'tomcat';
  "/var/cache/tomcat6":
    owner   => 'tomcat',
    group   => 'tomcat';
  }

  if $candlepin::params::reset_data == 'YES' {
    exec {"reset_candlepin_db":
      command => "rm -f /var/lib/katello/cpdb_done; rm -f /var/lib/katello/cpinit_done; service tomcat6 stop; test 1 -eq 1",
      path    => "/sbin:/bin:/usr/bin",
      before  => Exec["cpdb"],
      notify  => Postgres::Dropdb["$candlepin::params::db_name"],
    }
    postgres::dropdb {$candlepin::params::db_name:
      logfile => "${katello::params::configure_log_base}/drop-postgresql-candlepin-database.log",
      require => [ Postgres::Createuser[$candlepin::params::db_user], File["${katello::params::configure_log_base}"] ],
      before  => Exec["cpdb"],
      refreshonly => true,
      notify  => [
        Exec["cpdb"],
        Exec["cpinit"],
      ],
    }
  }

  exec { "cpdb":
    path    => "/bin:/usr/bin",
    command => "/usr/share/candlepin/cpdb --create -u '${candlepin::params::db_user}' -d '${candlepin::params::db_name}' -p '${candlepin::params::db_pass}' >> ${candlepin::params::cpdb_log} 2>&1 && touch /var/lib/katello/cpdb_done",
    require => [
      File["${katello::params::configure_log_base}"],
      Postgres::Createuser[$candlepin::params::db_user],
      File["/etc/candlepin/candlepin.conf"]
    ],
    creates => "/var/lib/katello/cpdb_done",
    before  => Class["apache2::service"],
  }

}
