class katello::config {

  postgres::createuser { $katello::params::db_user:
    passwd => $katello::params::db_pass,
  }
  postgres::createdb {$katello::params::db_name:
    owner   => $katello::params::db_user,
    require => Postgres::Createuser[$katello::params::db_user],
  }

  config_file {
    "${katello::params::config_dir}/thin.yml":
      template => "katello/${katello::params::config_dir}/thin.yml.erb";
    "${katello::params::config_dir}/katello.yml":
      template => "katello/${katello::params::config_dir}/katello.yml.erb";
    "/etc/httpd/conf.d/katello.conf":
      template => "katello/etc/httpd/conf.d/katello.conf.erb",
      notify   => Exec["reload-apache2"];
  }
  file{"/var/log/katello":
    owner   => $katello::params::user,
    group   => $katello::params::group,
    mode    => 644,
    require => Class["katello::install"],
    recurse => true;
  }

  exec {"katello_db_migrate":
    cwd         => $katello::params::katello_dir,
    user        => $katello::params::user,
    environment => "RAILS_ENV=${katello::params::environment}",
    refreshonly => true,
    subscribe   => Package["katello"],
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
    command     => "/usr/bin/env rake db:seed >> ${katello::params::seed_log} 2>&1 && touch /var/lib/katello/initdb_done",
    creates => "/var/lib/katello/initdb_done",
    before  => Class["katello::service"],
    require => [ Exec["katello_db_migrate"], Class["candlepin::service"], Class["pulp::service"] ],
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
      require => Class["katello::install"];
    }
  }
}
