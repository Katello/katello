class katello::params {

  if ($operatingsystem == "RedHat" or "CentOS"){
    $scl_prefix = 'ruby193-'
  } else {
    $scl_prefix = ''
  }

  # First User and Org settings
  $user_name = katello_config_value('user_name')
  $user_pass = katello_config_value('user_pass')
  $user_email = katello_config_value('user_email')
  $org_name  = katello_config_value('org_name')

  # database settings
  $db_user = katello_config_value('db_user')
  $db_name = katello_config_value('db_name')
  $db_pass = katello_config_value('db_password')
  $deployment_url = katello_config_value('deployment')

  case $deployment_url {
      'cfse': {
        $deployment = 'katello' 
      }
      'katello': {
        $deployment = 'katello' 
      }
      'sam': {
        $deployment = 'headpin' 
      }
      'headpin': {
        $deployment = 'headpin' 
      }
      default : {
	$deployment = katello_config_value('deployment') 
      }
  }

  # HTTP Proxy settings (currently used by pulp)
  $proxy_url = katello_config_value('proxy_url')
  $proxy_port = katello_config_value('proxy_port')
  $proxy_user = katello_config_value('proxy_user')
  $proxy_pass = katello_config_value('proxy_pass')

  # system settings
  $host        = katello_config_value('host')
  $user        = "katello"
  $group       = "katello"
  $config_dir  = "/etc/katello"
  $katello_dir = "/usr/share/katello"
  $environment = "production"
  $log_base    = "/var/log/katello"
  $configure_log_base = "$log_base/katello-configure"
  $db_env_log  = "$configure_log_base/db_env.log"
  $migrate_log = "$configure_log_base/db_migrate.log"
  $seed_log    = "$configure_log_base/db_seed.log"

  # katello upgrade settings
  $katello_upgrade_scripts_dir  = "/usr/share/katello/install/upgrade-scripts"
  $katello_upgrade_history_file = "/var/lib/katello/upgrade-history"

  # SSL settings
  $ssl_certificate_file     = "/etc/candlepin/certs/candlepin-ca.crt"
  $ssl_certificate_key_file = "/etc/candlepin/certs/candlepin-ca.key"
  $ssl_certificate_ca_file  = $ssl_certificate_file

  # Foreman settings (only if the foreman pieces are installed)
  if defined(foreman) {
      $use_foreman = true
  } else {
      $use_foreman = false
  }
  $install_foreman = false
  $foreman_start_port         = "5500"
  $foreman_thin_process_count = katello_config_value('foreman_web_workers', katello_process_count(0.4))

  # apache settings
  $thin_start_port = "5000"
  $thin_log        = "$log_base/thin-log.log"
  if $use_foreman {
    $default_process_count   = katello_process_count(0.6)
  } else {
    $default_process_count   = katello_process_count(1)
  }
  $process_count = katello_config_value('katello_web_workers', $default_process_count)

  # sysconfig settings
  $job_workers = katello_config_value('job_workers')

  # LDAP settings
  $ldap_server = katello_config_value('ldap_server')
  $ldap_port = katello_config_value('ldap_port')
  $ldap_server_type = katello_config_value('ldap_server_type')
  $ldap_encryption = katello_config_value('ldap_encryption')
  $ldap_users_basedn = katello_config_value('ldap_users_basedn')
  $ldap_groups_basedn = katello_config_value('ldap_groups_basedn')
  $ldap_roles = katello_config_value('ldap_roles')
  $ldap_service_user = katello_config_value('ldap_service_user')
  $ldap_service_pass = katello_config_value('ldap_service_pass')
  $ldap_anon_queries = katello_config_value('ldap_anon_queries')
  $ldap_ad_domain = katello_config_value('ldap_ad_domain')

  # auth method
  $auth_method = katello_config_value('auth_method') 

  # OAUTH settings
  $oauth_key    = "katello"
  # we set foreman oauth key to foreman, so that katello knows where the call
  # comes from and can find the rigth secret. This way only one key-secret pair
  # is needed to be mainained for duplex communication.
  $foreman_oauth_key    = "foreman"
  $oauth_secret = katello_create_read_password(katello_config_value('oauth_token_file'))

  # Subsystems settings
  $candlepin_url = "https://localhost:8443/candlepin"
  $pulp_url      = katello_pulp_url()
  $foreman_url   = "https://localhost/foreman"

  # database reinitialization flag
  $reset_data = katello_config_value('reset_data')
}
