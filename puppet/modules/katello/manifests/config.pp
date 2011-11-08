class katello::config {

  postgres::createuser { $katello::params::db_user:
    passwd => $katello::params::db_pass,
    logfile  => '/var/log/katello/katello-configure/create-postgresql-katello-user.log',
  }
  postgres::createdb {$katello::params::db_name:
    owner   => $katello::params::db_user,
    require => Postgres::Createuser[$katello::params::db_user],
    logfile  => '/var/log/katello/katello-configure/create-postgresql-katello-database.log',
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
  file{"/var/log/katello":
    owner   => $katello::params::user,
    group   => $katello::params::group,
    mode    => 644,
    recurse => true;
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

  common::simple_replace { "org_name":
      file => "/usr/share/katello/db/seeds.rb",
      pattern => "ACME_Corporation",
      replacement => "$katello::params::org_name",
      before => Exec["katello_seed_db"],
      require => $katello::params::deployment ? {
                'katello' => [ Class["candlepin::service"], Class["pulp::service"]  ],
                'headpin' => [ Class["candlepin::service"] ],
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
                'headpin' => [ Class["candlepin::service"] ],
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
                'headpin' => [ Class["candlepin::service"] ],
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
                'headpin' => [ Class["candlepin::service"] ],
                default => [],
    },
  }

  common::simple_replace { "primary_user_email":
      file => "/usr/share/katello/db/seeds.rb",
      pattern => "email => 'root@localhost'",
      replacement => "email => '$katello::params::user_email'",
      before => Exec["katello_seed_db"],
      require => [ Class["candlepin::service"], Class["pulp::service"] ],
  }

  exec {"katello_db_migrate":
    cwd         => $katello::params::katello_dir,
    user        => $katello::params::user,
    environment => "RAILS_ENV=${katello::params::environment}",
    refreshonly => true,
    require     => [ Config_file["${katello::params::config_dir}/katello.yml"],
                     Postgres::Createdb[$katello::params::db_name] ],
    command     => "/usr/bin/env rake db:migrate >> ${katello::params::migrate_log} 2>&1",
  }

  # seed our DB across pulp/candlepin and katello
  # should only run once.
  exec {"katello_seed_db":
    cwd         => $katello::params::katello_dir,
    user        => $katello::params::user,
    environment => "RAILS_ENV=${katello::params::environment}",
    command     => "/bin/env >> ${katello::params::seed_log} 2>&1 && /bin/echo \" Starting Migrate \" >> ${katello::params::seed_log} 2>&1 && /usr/bin/env rake db:migrate --trace --verbose >> ${katello::params::seed_log} 2>&1 && /bin/echo \" Starting Seed \" >> ${katello::params::seed_log} 2>&1 && /usr/bin/env rake db:seed --trace --verbose >> ${katello::params::seed_log} 2>&1 && touch /var/lib/katello/initdb_done",
    creates => "/var/lib/katello/initdb_done",
    before  => Class["katello::service"],
    require => $katello::params::deployment ? {
                'katello' => [ Exec["katello_db_migrate"], Class["candlepin::service"], Class["pulp::service"] ],
                'headpin' => [ Exec["katello_db_migrate"], Class["candlepin::service"] ],
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
