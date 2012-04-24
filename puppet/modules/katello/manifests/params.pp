class katello::params {
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
  $db_env_log  = "$log_base/katello-configure/db_env.log"
  $migrate_log = "$log_base/katello-configure/db_migrate.log"
  $seed_log    = "$log_base/katello-configure/db_seed.log"

  # SSL settings
  #$ssl_certificate_file     = "/etc/pki/tls/certs/httpd-ssl.crt"
  #$ssl_certificate_key_file = "/etc/pki/tls/private/httpd-ssl.key"
  #$ssl_certificate_ca_file  = "/usr/share/katello/KATELLO-TRUSTED-SSL-CERT"
  $ssl_certificate_file     = "/etc/candlepin/certs/candlepin-ca.crt"
  $ssl_certificate_key_file = "/etc/candlepin/certs/candlepin-ca.key"
  $ssl_certificate_ca_file  = $ssl_certificate_file

  # apache settings
  $thin_start_port = "5000"
  $thin_log        = "$log_base/thin-log.log"
  $process_count   = katello_process_count()

  # LDAP settings
  $ldap_server = katello_config_value('ldap_server')
  $ldap_encryption = katello_config_value('ldap_encryption')
  $ldap_basedn = katello_config_value('ldap_basedn')
  $ldap_groups_basedn = katello_config_value('ldap_groups_basedn')
  $ldap_roles = katello_config_value('ldap_roles')

  # auth method
  $auth_method = katello_config_value('auth_method') 

  # OAUTH settings
  $oauth_key    = "katello"
  $oauth_secret = regsubst(generate('/usr/bin/openssl', 'rand', '-base64', '24'), '^(.{24}).*', '\1')

  # Subsystems settings
  $candlepin_url = "https://localhost:8443/candlepin"
  $pulp_url      = katello_pulp_url()
  $foreman_url   = "https://localhost/foreman"
}
