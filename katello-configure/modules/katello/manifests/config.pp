class katello::config {
  include katello::config::files

  postgres::createuser { $katello::params::db_user:
    passwd  => $katello::params::db_pass,
    logfile => "${katello::params::configure_log_base}/create-postgresql-katello-user.log",
    require => [ Class["postgres::service"], File["${katello::params::configure_log_base}"] ],
  }

  postgres::createdb {$katello::params::db_name:
    owner   => $katello::params::db_user,
    logfile => "${katello::params::configure_log_base}/create-postgresql-katello-database.log",
    require => [ Postgres::Createuser[$katello::params::db_user], File["${katello::params::configure_log_base}"] ],
  }

  File["${katello::params::config_dir}/katello.yml"] ~> Exec["reload-apache2"]
  File["/etc/sysconfig/katello"] ~> Exec["reload-apache2"]
  File["/etc/httpd/conf.d/katello.conf"] ~> Exec["reload-apache2"]
  File["/etc/httpd/conf.d/katello.d/katello.conf"] ~> Exec["reload-apache2"]

  exec {"httpd-restart":
    command => "/bin/sleep 5; /sbin/service httpd restart; /bin/sleep 10",
    onlyif => "/usr/sbin/apachectl -t",
    before => Exec["katello_seed_db"],
    require   => $katello::params::deployment ? {
        'katello' => [ File["${katello::params::config_dir}/katello.yml"], Class["candlepin::service"], Class["pulp::service"] ],
        'headpin' => [ File["${katello::params::config_dir}/katello.yml"], Class["candlepin::service"], Class["thumbslug::service"] ],
         default  => [],
    },
    refreshonly => true,
  }

  exec {"katello_db_printenv":
    cwd         => $katello::params::katello_dir,
    user        => $katello::params::user,
    environment => "RAILS_ENV=${katello::params::environment}",
    command     => "/usr/bin/env > ${katello::params::db_env_log}",
    creates => "${katello::params::db_env_log}",
    before  => Class["katello::service"],
    require => $katello::params::deployment ? {
                'katello' => [
                  Class["candlepin::service"], 
                  Class["pulp::service"], 
                  File["${katello::params::log_base}"], 
                  File["${katello::params::log_base}/production.log"], 
                  File["${katello::params::log_base}/production_sql.log"], 
                  File["${katello::params::config_dir}/katello.yml"],
                  Postgres::Createdb[$katello::params::db_name]
                ],
                'headpin' => [
                  Class["candlepin::service"],
                  Class["thumbslug::service"],
                  File["${katello::params::log_base}"],
                  File["${katello::params::config_dir}/katello.yml"],
                  Postgres::Createdb[$katello::params::db_name]
                ],
                default => [],
    },
  }

  if $katello::params::reset_data == 'YES' {
    exec {"reset_katello_db":
      command => "rm -f /var/lib/katello/db_seed_done; rm -f /var/lib/katello/db_migrate_done; service katello stop; service katello-jobs stop; test 1 -eq 1",
      path    => "/sbin:/bin:/usr/bin",
      before  => Exec["katello_migrate_db"],
      notify  => Postgres::Dropdb["$katello::params::db_name"],
    }
    postgres::dropdb {$katello::params::db_name:
      logfile => "${katello::params::configure_log_base}/drop-postgresql-katello-database.log",
      require => [ Postgres::Createuser[$katello::params::db_user], File["${katello::params::configure_log_base}"] ],
      before  => Exec["katello_migrate_db"],
      refreshonly => true,
      notify  => [
        Postgres::Createdb[$katello::params::db_name],
        Exec["katello_db_printenv"],
        Exec["katello_migrate_db"],
        Exec["katello_seed_db"],
      ],
    }
  }

  exec {"katello_migrate_db":
    cwd         => $katello::params::katello_dir,
    user        => "root",
    environment => ["RAILS_ENV=${katello::params::environment}", "BUNDLER_EXT_NOSTRICT=1"],
    command     => "/usr/bin/${katello::params::scl_prefix}rake db:migrate --trace --verbose > ${katello::params::migrate_log} 2>&1 && touch /var/lib/katello/db_migrate_done",
    creates => "/var/lib/katello/db_migrate_done",
    before  => Class["katello::service"],
    require => [ Exec["katello_db_printenv"] ],
  }

  exec {"katello_seed_db":
    cwd         => $katello::params::katello_dir,
    user        => "root",
    environment => ["RAILS_ENV=${katello::params::environment}", "KATELLO_LOGGING=debug", "BUNDLER_EXT_NOSTRICT=1"],
    command     => "/usr/bin/${katello::params::scl_prefix}rake seed_with_logging --trace --verbose > ${katello::params::seed_log} 2>&1 && touch /var/lib/katello/db_seed_done",
    creates => "/var/lib/katello/db_seed_done",
    before  => Class["katello::service"],
    require => $katello::params::deployment ? {
                'katello' => [ Exec["katello_migrate_db"], Class["candlepin::service"], Class["pulp::service"], File["${katello::params::log_base}"] ],
                'headpin' => [ Exec["katello_migrate_db"], Class["candlepin::service"], Class["thumbslug::service"], File["${katello::params::log_base}"] ],
                default => [],
    },
  }

  # during first installation we mark all 'once'  upgrade scripts as executed
  exec {"update_upgrade_history":
    cwd     => "${katello::params::katello_upgrade_scripts_dir}",
    command => "grep -E '#.*run:.*once' * | awk -F: '{print \$1}' > ${katello::params::katello_upgrade_history_file}",
    creates => "${katello::params::katello_upgrade_history_file}",
    path    => "/bin",
    before  => Class["katello::service"],
  }

  # Headpin does not care about pulp
  case $katello::params::deployment {
    'katello': {
      Class["candlepin::config"] -> File["/etc/pulp/server.conf"]
      Class["candlepin::config"] -> File["/etc/pulp/repo_auth.conf"]
      Class["candlepin::config"] -> File["/etc/pki/pulp/content/pulp-global-repo.ca"]
    }
    default : {}
  }
  
  if $katello::params::use_foreman {
    Class["foreman::service"] -> Exec["katello_db_printenv"]
    Class["foreman::service"] -> Exec["katello_seed_db"]
    Class["foreman"] -> Class["katello::config"]
  }
}
