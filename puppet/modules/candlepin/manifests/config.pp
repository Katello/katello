class candlepin::config {

  exec { "add-tomcat-user-to-katello-group":
        command => "usermod -a -G katello tomcat",
        path => "/usr/sbin",
        before => Exec["cpsetup"]
  }

  postgres::createuser { $candlepin::params::db_user:
    passwd => $candlepin::params::db_pass,
    roles  => "CREATEDB",
    logfile  => "${katello::params::log_base}/katello-configure/create-postgresql-candlepin-user.log",
    require => [ File["${katello::params::log_base}"] ],
  }

  # cpsetup drops our db, safe to keep it here until this gets fixed in cpsetup
  postgres::createdb {$candlepin::params::db_name:
    owner   => $candlepin::params::db_user,
    logfile  => "${katello::params::log_base}/katello-configure/create-postgresql-candlepin-database.log",
    require => [ File["${katello::params::log_base}"], Postgres::Createuser[$candlepin::params::db_user] ],
  }

  file { "/etc/candlepin/candlepin.conf":
    content => template("candlepin/etc/candlepin/candlepin.conf.erb"),
    require => Exec["cpsetup"],
    notify  => Service["tomcat6"];
  }
  common::line { "allow_cpsetup_to_execute_sudo_HACK":
      file => "/etc/sudoers",
      line    => "Defaults:root !requiretty",
      before => Exec["cpsetup"];
  }

  # this does not really work if you use a password
   exec {"cpsetup":
     command => "/usr/share/candlepin/cpsetup >> ${candlepin::params::cpsetup_log} 2>&1",
     timeout => 300, # 5 minutes timeout (cpsetup can be really slow sometimes)
     require => [
       Postgres::Createdb[$candlepin::params::db_name],
       Class["certs::config"]
     ],
     creates => "/etc/tomcat6/server.xml.original", # another hack not to run it again
     #creates => "/etc/candlepin/certs/candlepin-ca.crt", # another hack not to run it again
     before  => Class["apache2::service"],               # another hack, as we reuse cp certs by default
   }
}
