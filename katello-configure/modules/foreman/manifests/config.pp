class foreman::config {

  file { $foreman::app_root:
    ensure  => directory,
  }

  # cleans up the session entries in the database
  # if you are using fact or report importers, this creates a session per
  # request which can easily result with a lot of old and unrequired in your
  # database eventually slowing it down.
  cron{'clear_session_table':
    environment => ["RAILS_ENV=${foreman::environment}", "BUNDLER_EXT_NOSTRICT=1"],
    command => "(cd ${foreman::app_root} && /usr/bin/${katello::params::scl_prefix}rake  db:sessions:clear)",
    minute  => '15',
    hour    => '23',
  }

  postgres::createuser { $foreman::db_user:
    passwd  => $foreman::db_pass,
    logfile => "${foreman::configure_log_base}/create-postgresql-foreman-user.log",
    require => [ File["${foreman::configure_log_base}"] ],
  }

  postgres::createdb {$foreman::db_name:
    owner   => $foreman::db_user,
    logfile => "${foreman::configure_log_base}/create-postgresql-foreman-database.log",
    require => [ Postgres::Createuser[$foreman::db_user], File["${foreman::log_base}"] ],
  }

  user { $foreman::user:
    ensure  => 'present',
    shell   => '/sbin/nologin',
    comment => 'Foreman',
    home    => $foreman::app_root,
  }

  file {
    "${foreman::log_base}":
      owner   => $foreman::user,
      group   => $foreman::group,
      mode    => 750;

    # create Rails logs in advance to get correct owners and permissions
    "${foreman::log_base}/production.log":
      owner   => $foreman::user,
      group   => $foreman::group,
      content => "",
      replace => false,
      mode    => 640,
      require => File["${foreman::log_base}"];

    "${foreman::config_dir}/settings.yaml":
      content => template('foreman/settings.yaml.erb'),
      owner   => $foreman::user;

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
      ensure    => absent;

    "/etc/httpd/conf.d/katello.d/foreman.conf":
      content => template("foreman/httpd.conf.erb"),
      owner   => $foreman::user,
      group   => $foreman::user,
      mode    => "600",
      notify  => Exec["reload-apache2"],
      before  => Class["apache2::service"];
  }

  exec {"generate_token":
    cwd         => $foreman::app_root,
    environment => ["RAILS_ENV=${foreman::environment}", "BUNDLER_EXT_NOSTRICT=1"],
    command     => "/usr/bin/${katello::params::scl_prefix}rake security:generate_token",
    path        => "/bin:/usr/bin",
    creates     => "${foreman::app_root}/config/initializers/local_secret_token.rb",
  }

  $foreman_config_cmd = "/usr/bin/${katello::params::scl_prefix}ruby ${foreman::app_root}/script/foreman-config -k oauth_active -v '${foreman::oauth_active}'\
                              -k foreman_url -v '${fqdn}'\
                              -k katello_url -v '${foreman::katello_url}'\
                              -k token_duration -v '60'\
                              -k manage_puppetca -v false\
                              -k oauth_consumer_key -v '${foreman::oauth_consumer_key}'\
                              -k oauth_consumer_secret -v '${foreman::oauth_consumer_secret}'\
                              -k oauth_map_users -v '${foreman::oauth_map_users}'\
                              -k administrator -v '${foreman::administrator}'"

  exec {"foreman_migrate_db":
    cwd         => $foreman::app_root,
    environment => ["RAILS_ENV=${foreman::environment}", "BUNDLER_EXT_NOSTRICT=1"],
    command     => "/usr/bin/${katello::params::scl_prefix}rake db:migrate --trace --verbose > ${foreman::configure_log_base}/foreman-db-migrate.log 2>&1 && touch /var/lib/katello/foreman_db_migrate_done",
    path        => "/sbin:/usr/sbin:/bin:/usr/bin",
    creates     => "/var/lib/katello/foreman_db_migrate_done",
    require     => [ Postgres::Createdb[$foreman::db_name],
                 File["${foreman::log_base}/production.log"],
                 File["${foreman::config_dir}/settings.yaml"],
                 File["${foreman::config_dir}/database.yml"],
                 Exec["generate_token"],
                 ];
  } ~>

  exec {"foreman_config":
   cwd     => $foreman::app_root,
   command => $foreman_config_cmd,
   unless  => "$foreman_config_cmd --dry-run",
   user    => $foreman::user,
   require => User[$foreman::user],
  }

  if $foreman::reset_data == 'YES' {
   exec {"reset_foreman_db":
      command => "rm -f /var/lib/katello/foreman_db_migrate_done; if service foreman status ; then /usr/sbin/service-wait foreman stop; else true; fi",
      path    => "/sbin:/bin:/usr/bin",
      before  => Exec["foreman_migrate_db"],
    } ~>

    postgres::dropdb {$foreman::db_name:
      logfile => "${foreman::configure_log_base}/drop-postgresql-foreman-database.log",
      require => [ Postgres::Createuser[$foreman::db_user], File["${foreman::configure_log_base}"] ],
      before  => Exec["foreman_migrate_db"],
      refreshonly => true,
      notify  => [
                  Postgres::Createdb[$foreman::db_name],
                  Exec["foreman_migrate_db"],
                  ],
    }
  }

}
