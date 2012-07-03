class candlepin::params {
  $db_user = katello_config_value('candlepin_db_user')
  $db_name = katello_config_value('candlepin_db_name')

  # this comes from keystore
  $db_pass = katello_config_value('candlepin_db_password')

  # password for server.xml keystore
  $tomcat_keystore_password = katello_create_read_password(katello_config_value('tomcat_keystore_password_file'))

  # where to store output from cpsetup execution
  $cpsetup_log = "${katello::params::log_base}/katello-configure/cpsetup.log"
  $crl_file = "/var/lib/candlepin/candlepin-crl.crl"

  require "katello::params"
  $katello_oauth_key = $katello::params::oauth_key
  $katello_oauth_secret = $katello::params::oauth_secret

  case $katello::params::deployment {
    'headpin' : {
      require "thumbslug::params"
      $thumbslug_oauth_key = "thumbslug"
      $thumbslug_oauth_secret = $thumbslug::params::oauth_secret
      $env_filtering_enabled = "false"
    }
    default : {
      $env_filtering_enabled = "true"
    }
  }

}
