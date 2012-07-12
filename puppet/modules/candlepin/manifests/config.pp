class candlepin::config {

  user { 'tomcat':
    ensure => present,
    groups => ['katello'],
    before => Exec["cpsetup"]
  }

  postgres::createuser { $candlepin::params::db_user:
    passwd => $candlepin::params::db_pass,
    roles  => "CREATEDB",
    logfile  => "${katello::params::log_base}/katello-configure/create-postgresql-candlepin-user.log",
    require => [ File["${katello::params::log_base}"] ],
  }

  # we shoud notify tomcat6 but cpsetup does that for us
  file { "/etc/candlepin/candlepin.conf":
    content => template("candlepin/etc/candlepin/candlepin.conf.erb"),
    mode    => '600',
    owner   => 'tomcat';
  }

  # TODO fix "sudo" in candlepin and remove me
  common::line { "allow_cpsetup_to_execute_sudo_HACK":
    file => "/etc/sudoers",
    line    => "Defaults:root !requiretty",
    before => Exec["cpsetup"];
  }

  exec { "cpsetup":
    command => "/usr/share/candlepin/cpsetup -k ${candlepin::params::keystore_password} -s -u ${candlepin::params::db_user} -d ${candlepin::params::db_name} >> ${candlepin::params::cpsetup_log} 2>&1 && touch /var/lib/katello/cpsetup_done",
    timeout => 300, # 5 minutes timeout (cpsetup takes longer sometimes)
    require => [
      File["${katello::params::log_base}"],
      Postgres::Createuser[$candlepin::params::db_user],
      File["/etc/candlepin/candlepin.conf"]
    ],
    creates => "/var/lib/katello/cpsetup_done",
    before  => Class["apache2::service"]
  }
}
