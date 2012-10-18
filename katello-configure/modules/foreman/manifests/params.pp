class foreman::params {
  # should be foreman installed (not only configured) as well?
  $install     = false
  # should foreman manage host provisioning as well
  $unattended   = true
  # Enable users authentication (default user:admin pw:changeme)
  $authentication = false
  # force SSL (note: requires passenger)
  $ssl         = false

  $user        = 'foreman'
  $group       = 'foreman'
  $environment = 'production'

  $app_root    = "/usr/share/foreman"

  $config_dir         = "/etc/foreman"
  $log_base           = "/var/log/foreman"
  $configure_log_base = "/var/log/foreman"

  $db_user = "foreman"
  $db_name = "foreman"
  $db_pass = "foreman"

  $thin_ip            = "0.0.0.0"
  $thin_start_port    = "5500"
  $thin_log           = "/var/log/foreman/thin-log.log"
  $thin_process_count = 2
  $deployment_url     = "foreman"

  # should oauth be used?
  $oauth_active       = false
  $oauth_consumer_key = "key"
  $oauth_consumer_secret = "secret"
  # use header to specify the user to map to the actions performed through oauth
  $oauth_map_users    = true
}
