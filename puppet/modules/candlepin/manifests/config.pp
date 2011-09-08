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

  common::line {
    "katellomodule":
      line    => "module.config.katello=org.fedoraproject.candlepin.katello.KatelloModule",
      file    => "/etc/candlepin/candlepin.conf",
      require => Exec["cpsetup"],
      notify  => Service["tomcat6"];
    "allow_cpsetup_to_execute_sudo_HACK":
      file => "/etc/sudoers",
      line    => "Defaults:root !requiretty",
      before => Exec["cpsetup"];
  }

  # this does not really work if you use a password
   exec {"cpsetup":
     command => "/usr/share/candlepin/cpsetup >> /tmp/cpsetup.log 2>&1",
     require => [Class["postgres::install"],Postgres::Createdb[$candlepin::params::db_name]],
     creates => "/etc/candlepin/certs/candlepin-ca.crt", # another hack not to run it again
   }
}
