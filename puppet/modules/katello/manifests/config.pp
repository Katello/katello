class katello::config {

  # this should be required by all classes that need to log there (everytime $log_base is used)
  # TODO this actually mangles file permissions - we should get rid of it (WHY we do this?)
  file { "${katello::params::log_base}":
    owner   => $katello::params::user,
    group   => $katello::params::group,
    mode    => 640,
    recurse => true;
  }

  # create Rails logs in advance to get correct owners and permissions
  file {[
    "${katello::params::log_base}/production.log",
    "${katello::params::log_base}/production_sql.log",
    "${katello::params::log_base}/production_delayed_jobs.log",
    "${katello::params::log_base}/production_delayed_jobs_sql.log"]:
      owner   => $katello::params::user,
      group   => $katello::params::group,
      content => "",
      replace => false,
      mode    => 640,
      require => [ File["${katello::params::log_base}"] ];
  }

  postgres::createuser { $katello::params::db_user:
    passwd  => $katello::params::db_pass,
    roles => "CREATEDB",
    logfile => "${katello::params::log_base}/katello-configure/create-postgresql-katello-user.log",
    require => [ File["${katello::params::log_base}"] ],
  }

  postgres::createdb {$katello::params::db_name:
    owner   => $katello::params::db_user,
    logfile => "${katello::params::log_base}/katello-configure/create-postgresql-katello-database.log",
    require => [ Postgres::Createuser[$katello::params::db_user], File["${katello::params::log_base}"] ],
  }

  file {
    "${katello::params::config_dir}/thin.yml":
      content => template("katello/${katello::params::config_dir}/thin.yml.erb"),
      owner   => "root",
      group   => "root",
      mode    => "644";

    "${katello::params::config_dir}/katello.yml":
      content => template("katello/${katello::params::config_dir}/katello.yml.erb"),
      owner   => $katello::params::user,
      group   => $katello::params::group,
      mode    => "600";

    "/etc/sysconfig/katello":
      content => template("katello/etc/sysconfig/katello.erb"),
      owner   => "root",
      group   => "root",
      mode    => "644";

    "/etc/katello/client.conf":
      content => template("katello/etc/katello/client.conf.erb"),
      owner   => "root",
      group   => "root",
      mode    => "644";

    "/etc/httpd/conf.d/katello.conf":
      content => template("katello/etc/httpd/conf.d/katello.conf.erb"),
      owner   => $katello::params::user,
      group   => $katello::params::group,
      mode    => "600",
      notify  => Exec["reload-apache2"];
  }

  exec {"httpd-restart":
    command => "/bin/sleep 5; /sbin/service httpd restart; /bin/sleep 10",
    onlyif => "/usr/sbin/apachectl -t",
    before => Exec["katello_seed_db"],
    require   => $katello::params::deployment ? {
        'katello' => [ File["${katello::params::config_dir}/katello.yml"], Class["candlepin::service"], Class["pulp::service"] ],
        'headpin' => [ File["${katello::params::config_dir}/katello.yml"], Class["candlepin::service"], Class["thumbslug::service"] ],
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
                'katello' => [
                  Class["candlepin::service"], 
                  Class["pulp::service"], 
                  File["${katello::params::log_base}"], 
                  File["${katello::params::log_base}/production.log"], 
                  File["${katello::params::log_base}/production_sql.log"], 
                  File["${katello::params::config_dir}/katello.yml"],
                  Postgres::Createdb[$katello::params::db_name],
                  Common::Simple_replace["org_name"],
                  Common::Simple_replace["primary_user_name"],
                  Common::Simple_replace["primary_user_pass"],
                  Common::Simple_replace["primary_user_email"]
                ],
                'headpin' => [
                  Class["candlepin::service"],
                  Class["thumbslug::service"],
                  File["${katello::params::log_base}"],
                  File["${katello::params::config_dir}/katello.yml"],
                  Postgres::Createdb[$katello::params::db_name],
                  Common::Simple_replace["org_name"],
                  Common::Simple_replace["primary_user_name"],
                  Common::Simple_replace["primary_user_pass"],
                  Common::Simple_replace["primary_user_email"]
                ],
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
    environment => ["RAILS_ENV=${katello::params::environment}", "KATELLO_LOGGING=debug"],
    command     => "/usr/bin/env rake seed_with_logging --trace --verbose > ${katello::params::seed_log} 2>&1 && touch /var/lib/katello/db_seed_done",
    creates => "/var/lib/katello/db_seed_done",
    before  => Class["katello::service"],
    require => $katello::params::deployment ? {
                'katello' => [ Exec["katello_migrate_db"], File["${katello::params::log_base}"] ],
                'headpin' => [ Exec["katello_migrate_db"], File["${katello::params::log_base}"] ],
                default => [],
    },
  }

  exec {"update_upgrade_history":
    command => "ls ${katello::params::katello_upgrade_scripts_dir} > ${katello::params::katello_upgrade_history_file}",
    path    => "/bin",
    before  => Class["katello::service"],
  }

  # Headpin does not care about pulp
  case $katello::params::deployment {
      'katello': {
          Class["candlepin::config"] -> File["/etc/pulp/pulp.conf"]
          Class["candlepin::config"] -> File["/etc/pulp/repo_auth.conf"]
          Class["candlepin::config"] -> File["/etc/pki/pulp/content/pulp-global-repo.ca"]
      }
      default : {}
  }
}
