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

  file { "/etc/candlepin/candlepin.conf":
    content => template("candlepin/etc/candlepin/candlepin.conf.erb"),
    require => Exec["cpsetup"],
    mode    => '600',
    owner   => 'tomcat',
    notify  => Service["tomcat6"];
  }

  # TODO fix "sudo" in candlepin and remove me
  common::line { "allow_cpsetup_to_execute_sudo_HACK":
    file => "/etc/sudoers",
    line    => "Defaults:root !requiretty",
    before => Exec["cpsetup"];
  }

  # this does not really work if you use a password
  require "certs::params"
  exec { "cpsetup":
    command => "/usr/share/candlepin/cpsetup -k ${certs::params::keystore_password} -u ${candlepin::params::db_user} -d ${candlepin::params::db_name} >> ${candlepin::params::cpsetup_log} 2>&1 && touch /var/lib/katello/cpsetup_done",
    timeout => 300, # 5 minutes timeout (cpsetup takes longer sometimes)
    require => [
      File["${katello::params::log_base}"],
      Postgres::Createuser[$candlepin::params::db_user],
      Class["certs::config"]
    ],
    creates => "/var/lib/katello/cpsetup_done",
    before  => Class["apache2::service"]
  }
}
