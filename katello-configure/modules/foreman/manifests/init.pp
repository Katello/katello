class foreman (
  $install            = $foreman::params::install,
  $unattended         = $foreman::params::unattended,
  $authentication     = $foreman::params::authentication,
  $ssl                = $foreman::params::ssl,
  $user               = $foreman::params::user,
  $group              = $foreman::params::group,
  $environment        = $foreman::params::environment,

  $katello_url        = $foreman::params::katello_url,
  $oauth_active       = $foreman::params::oauth_active,
  $oauth_consumer_key = $foreman::params::oauth_consumer_key,
  $oauth_consumer_secret = $foreman::params::oauth_consumer_secret,
  $oauth_map_users    = $foreman::params::oauth_map_users,

  $db_user            = $foreman::params::db_user,
  $db_group           = $foreman::params::db_group,
  $db_pass            = $foreman::params::db_pass,

  $config_dir         = $foreman::params::config_dir,
  $log_base           = $foreman::params::log_base,
  $configure_log_base = $foreman::params::configure_log_base,

  $thin_ip            = $foreman::params::thin_ip,
  $thin_start_port    = $foreman::params::thin_start_port,
  $thin_log           = $foreman::params::thin_log,
  $thin_process_count = $foreman::params::thin_process_count,
  $deployment_url     = $foreman::params::deployment_url,

  $administrator      = $foreman::params::administrator,

  $reset_data         = $foreman::params::reset_data
  ) inherits foreman::params {
  Exec { logoutput => true, timeout => 0 }

  if $foreman::install {
    class { '::foreman::repos': } ~>
    class { '::foreman::install': } ~>
    Class['::foreman::config']
  }
  class { '::foreman::config': } ~>
  class { '::foreman::service': }
}
