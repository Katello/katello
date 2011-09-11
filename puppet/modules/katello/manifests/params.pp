class katello::params {
  # database settings
  $db_user = "katello"
  $db_name = "katello"
  $db_pass = "katello"

  # system settings
  $user        = "katello"
  $group       = "katello"
  $config_dir  = "/etc/katello"
  $katello_dir = "/usr/share/katello"

  # SSL settings
  $ssl_certificate_file     = "/etc/candlepin/certs/candlepin-ca.crt"
  $ssl_certificate_key_file = "/etc/candlepin/certs/candlepin-ca.key"

  # apache settings
  $thin_start_port = "5000"
  $thin_log        = "/var/log/katello/thin-log.log"

  # LDAP settings
  $ldap_server = "localhost"
  $ldap_basedn = "ou=People,dc=company,dc=com"

  # OAUTH settings
  $oauth_key    = "katello"
  $oauth_secret = "5JLGjZ0ThAMJd2i2C5oo2rl2" # TODO: Make this dynamic one time

  # Subsystems settings
  $candlepin_url = "https://localhost:8443/candlepin"
  $pulp_url      = "https://localhost/pulp/api"
  $foreman_url   = "https://localhost/foreman"
}
