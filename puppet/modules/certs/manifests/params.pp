class certs::params {

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
  $candlepin_ca_password_file = katello_config_value('candlepin_ca_password_file')
  $keystore_password_file = katello_config_value('keystore_password_file')
  $keystore_password = regsubst(generate('/usr/bin/openssl', 'rand', '-hex', '13'), '^(.{24}).*', '\1', 'M')
  $nss_db_password_file = katello_config_value('nss_db_password_file')
  $nss_db_dir = katello_config_value('nss_db_dir')
  $ssl_pk12_password_file = katello_config_value('ssl_pk12_password_file')
}
