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

  # seed our DB across pulp/candlepin and katello
  # should only run once.
  exec {"initkatello":
    command => "service katello initdb",
    path    => "/sbin",
    creates => "/var/lib/katello/initdb_done",
    before  => Class["katello::service"],
    require => [ Class["katello::install"], Postgres::Createdb[$katello::params::db_name],
                 Class["candlepin::service"], Class["pulp::service"] ],
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
