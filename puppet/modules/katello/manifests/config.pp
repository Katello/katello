class katello::config {

  # this should be required by all classes that need to log there (everytime $log_base is used)
  file { "${katello::params::log_base}":
    owner   => $katello::params::user,
    group   => $katello::params::group,
    mode    => 644,
    recurse => true;
  }

  postgres::createuser { $katello::params::db_user:
    passwd  => $katello::params::db_pass,
    logfile => "${katello::params::log_base}/katello-configure/create-postgresql-katello-user.log",
    require => [ File["${katello::params::log_base}"] ],
  }

  postgres::createdb {$katello::params::db_name:
    owner   => $katello::params::db_user,
    logfile => "${katello::params::log_base}/katello-configure/create-postgresql-katello-database.log",
    require => [ Postgres::Createuser[$katello::params::db_user], File["${katello::params::log_base}"] ],
  }

  config_file {
    "${katello::params::config_dir}/thin.yml":
      template => "katello/${katello::params::config_dir}/thin.yml.erb";
    "${katello::params::config_dir}/katello.yml":
      template => "katello/${katello::params::config_dir}/katello.yml.erb";
    "/etc/sysconfig/katello":
      template => "katello/etc/sysconfig/katello.erb";
    "/etc/httpd/conf.d/katello.conf":
      template => "katello/etc/httpd/conf.d/katello.conf.erb",
      notify   => Exec["reload-apache2"];
  }

  # disable SELinux
  augeas {"temp_disable_selinux":
    context => "/files/etc/sysconfig/selinux",
    changes => ["set SELINUX permissive"],
    notify   => Exec["reload-apache2"]
  }

  exec {"temp_setenforce":
    command => "setenforce 0",
    path    => "/usr/sbin:/bin",
    unless  => "getenforce |egrep -iq 'disable|Permissive'",
  }

  exec {"httpd-restart":
    command => "/bin/sleep 5; /sbin/service httpd restart; /bin/sleep 10",
    onlyif => "/usr/sbin/apachectl -t",
    before => Exec["katello_seed_db"],
    require   => $katello::params::deployment ? {
        'katello' => [ Config_file["${katello::params::config_dir}/katello.yml"], Class["candlepin::service"], Class["pulp::service"] ],
        'headpin' => [ Config_file["${katello::params::config_dir}/katello.yml"], Class["candlepin::service"], Class["thumbslug::service"] ],
         default  => [],
    },
  }

  common::simple_replace { "org_name":
      file => "/usr/share/katello/db/seeds.rb",
      pattern => "ACME_Corporation",
      replacement => "$katello::params::org_name",
      before => Exec["katello_seed_db"],
      require => $katello::params::deployment ? {
                'katello' => [ Class["candlepin::service"], Class["pulp::service"]  ],
                'headpin' => [ Class["candlepin::service"], Class["thumbslug::service"] ],
                default => [],
    },
  }

  common::simple_replace { "org_description":
      file => "/usr/share/katello/db/seeds.rb",
      pattern => "ACME Corporation Organization",
      replacement => "$katello::params::org_name Organization",
      before => Exec["katello_seed_db"],
      require => $katello::params::deployment ? {
                'katello' => [ Class["candlepin::service"], Class["pulp::service"]  ],
                'headpin' => [ Class["candlepin::service"], Class["thumbslug::service"] ],
                default => [],
    },
  }

  common::simple_replace { "primary_user_pass":
      file => "/usr/share/katello/db/seeds.rb",
      pattern => "password => 'admin'",
      replacement => "password => '$katello::params::user_pass'",
      before => Exec["katello_seed_db"],
      require => $katello::params::deployment ? {
                'katello' => [ Class["candlepin::service"], Class["pulp::service"]  ],
                'headpin' => [ Class["candlepin::service"], Class["thumbslug::service"] ],
                default => [],
    },
  }

  common::simple_replace { "primary_user_name":
      file => "/usr/share/katello/db/seeds.rb",
      pattern => "username => 'admin'",
      replacement => "username => '$katello::params::user_name'",
      before => Exec["katello_seed_db"],
      require => $katello::params::deployment ? {
                'katello' => [ Class["candlepin::service"], Class["pulp::service"]  ],
                'headpin' => [ Class["candlepin::service"], Class["thumbslug::service"] ],
                default => [],
    },
  }

  common::simple_replace { "primary_user_email":
      file => "/usr/share/katello/db/seeds.rb",
      pattern => "email => 'root@localhost'",
      replacement => "email => '$katello::params::user_email'",
      before => Exec["katello_seed_db"],
      require => $katello::params::deployment ? {
                'katello' => [ Class["candlepin::service"], Class["pulp::service"]  ],
                'headpin' => [ Class["candlepin::service"], Class["thumbslug::service"] ],
                default => [],
    },
  }

  exec {"katello_db_printenv":
    cwd         => $katello::params::katello_dir,
    user        => $katello::params::user,
    environment => "RAILS_ENV=${katello::params::environment}",
    command     => "/usr/bin/env > ${katello::params::db_env_log}",
    before  => Class["katello::service"],
    require => $katello::params::deployment ? {
                'katello' => [ Class["candlepin::service"], Class["pulp::service"], File["${katello::params::log_base}"] ],
                'headpin' => [ Class["candlepin::service"], Class["thumbslug::service"], File["${katello::params::log_base}"] ],
                default => [],
    },
  }

  exec {"katello_migrate_db":
    cwd         => $katello::params::katello_dir,
    user        => $katello::params::user,
    environment => "RAILS_ENV=${katello::params::environment}",
    command     => "/usr/bin/env rake db:migrate --trace --verbose > ${katello::params::migrate_log} 2>&1 && touch /var/lib/katello/db_migrate_done",
    creates => "/var/lib/katello/db_migrate_done",
    before  => Class["katello::service"],
    require => $katello::params::deployment ? {
                'katello' => [ Exec["katello_db_printenv"], File["${katello::params::log_base}"] ],
                'headpin' => [ Exec["katello_db_printenv"], File["${katello::params::log_base}"] ],
                default => [],
    },
  }

  exec {"katello_seed_db":
    cwd         => $katello::params::katello_dir,
    user        => $katello::params::user,
    environment => "RAILS_ENV=${katello::params::environment}",
    command     => "/usr/bin/env rake db:seed --trace --verbose > ${katello::params::seed_log} 2>&1 && touch /var/lib/katello/db_seed_done",
    creates => "/var/lib/katello/db_seed_done",
    before  => Class["katello::service"],
    require => $katello::params::deployment ? {
                'katello' => [ Exec["katello_migrate_db"], File["${katello::params::log_base}"] ],
                'headpin' => [ Exec["katello_migrate_db"], File["${katello::params::log_base}"] ],
                default => [],
    },
  }

  define config_file($source = "", $template = "") {
    file {$name:
      content => $template ? {
        "" => undef,
        default =>  template($template)
      },
      source => $source ? {
        "" => undef,
        default => $source,
      },
    }
  }

  # Headpin does not care about pulp
  case $katello::params::deployment {
      'katello': {
          Class["candlepin::config"] -> File["/etc/pulp/pulp.conf"]
          Class["candlepin::config"] -> File["/etc/pulp/repo_auth.conf"]
          Class["candlepin::config"] -> File["/etc/pki/content/pulp-global-repo.ca"]
      }
      default : {}
  }
}
