class candlepin::config {

  postgres::createuser { $candlepin::params::db_user:
    passwd => $candlepin::params::db_pass,
    roles  => "CREATEDB"
  }
  # cpsetup drops our db, safe to keep it here until this gets fixed in cpsetup
  postgres::createdb {$candlepin::params::db_name:
    owner   => $candlepin::params::db_user,
    require => Postgres::Createuser[$candlepin::params::db_user],
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
     require => [
       Class["candlepin::install"],Class["postgres::install"],
       Postgres::Createdb[$candlepin::params::db_name]
     ],
     creates => "/etc/candlepin/certs/candlepin-ca.crt", # another hack not to run it again
     before  => Class["apache2::service"],               # another hack, as we reuse cp certs by default
   }
}
