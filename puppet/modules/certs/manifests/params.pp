class certs::params {

  $skip_ssl_ca_generation = katello_config_value('skip_ssl_ca_generation')

  # SSL settings
  $ssl_ca_pw = katello_config_value('ssl_ca_password')
  $ssl_ca_country = katello_config_value('ssl_ca_country')
  $ssl_ca_state = katello_config_value('ssl_ca_state')
  $ssl_ca_city = katello_config_value('ssl_ca_city')
  $ssl_ca_org = katello_config_value('ssl_ca_org')
  $ssl_ca_org_unit = katello_config_value('ssl_ca_org_unit')
  $ssl_ca_cn = katello_config_value('ssl_ca_cn')
  $ssl_ca_email = katello_config_value('ssl_ca_email')

  $ssl_cert_expiration = katello_config_value('ssl_cert_expiration')

  $ssl_ca_password_file = katello_config_value('ssl_ca_password_file')
  $keystore_password_file = katello_config_value('keystore_password_file')
  $nss_db_password_file = katello_config_value('nss_db_password_file')
}
