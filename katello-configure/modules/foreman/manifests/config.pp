class foreman::config {

  file {'/etc/foreman/settings.yaml':
    content => template('foreman/settings.yaml.erb'),
    owner   => $foreman::user,
    require => User[$foreman::user],
  }

  file { $foreman::app_root:
    ensure  => directory,
  }

  user { $foreman::user:
    ensure  => 'present',
    shell   => '/sbin/nologin',
    comment => 'Foreman',
    home    => $foreman::app_root,
  }

  # cleans up the session entries in the database
  # if you are using fact or report importers, this creates a session per
  # request which can easily result with a lot of old and unrequired in your
  # database eventually slowing it down.
  cron{'clear_session_table':
    command => "(cd ${foreman::app_root} && rake db:sessions:clear)",
    minute  => '15',
    hour    => '23',
  }

  file { "${foreman::log_base}":
    owner   => $foreman::user,
    group   => $foreman::group,
    mode    => 640,
    recurse => true;
  }

  postgres::createuser { $foreman::db_user:
    passwd  => $foreman::db_pass,
    roles => "CREATEDB",
    logfile => "${foreman::configure_log_base}/create-postgresql-foreman-user.log",
    require => [ File["${foreman::configure_log_base}"] ],
  }

  postgres::createdb {$foreman::db_name:
    owner   => $foreman::db_user,
    logfile => "${foreman::configure_log_base}/create-postgresql-foreman-database.log",
    require => [ Postgres::Createuser[$foreman::db_user], File["${foreman::log_base}"] ],
  }

  file {
    "${foreman::config_dir}/thin.yml":
      content => template("foreman/thin.yml.erb"),
      owner   => "root",
      group   => "root",
      mode    => "644";

    "${foreman::config_dir}/database.yml":
      content => template("foreman/database.yml.erb"),
      owner   => $foreman::user,
      group   => $foreman::user,
      mode    => "600";

    "/etc/sysconfig/foreman":
      content => template("foreman/sysconfig.erb"),
      owner   => "root",
      group   => "root",
      mode    => "644";

    "/etc/httpd/conf.d/foreman.conf":
      content => template("foreman/httpd.conf.erb"),
      owner   => $foreman::user,
      group   => $foreman::user,
      mode    => "600";
  }

  exec {"foreman_migrate_db":
    cwd         => $foreman::app_root,
    environment => "RAILS_ENV=${foreman::environment}",
    command     => "/usr/bin/env rake db:migrate --trace --verbose > ${foreman::configure_log_base}/foreman-db-migrate.log 2>&1 && touch /var/lib/katello/foreman_db_migrate_done",
    creates => "/var/lib/katello/foreman_db_migrate_done",
    require => [ Postgres::Createdb[$foreman::db_name] ];
  }

}
