class candlepin::params {
  $db_user = "candlepin"
  $db_name = "candlepin"
  $db_pass = "candlepin"
  # where to store output from cpsetup execution
  $cpsetup_log = "${katello::params::log_base}/katello-configure/cpsetup.log"
  $crl_file = "/var/lib/candlepin/candlepin-crl.crl"

  require "katello::params"
  $katello_oauth_key = $katello::params::oauth_key
  $katello_oauth_secret = $katello::params::oauth_secret

  require "thumbslug::params"
  $thumbslug_oauth_secret = $thumbslug::params::oauth_secret
}
