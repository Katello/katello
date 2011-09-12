class candlepin::params {
  $db_user = "candlepin"
  $db_name = "candlepin"
  $db_pass = "candlepin"
  # where to store output from cpsetup execution
  $cpsetup_log = "/tmp/cpsetup.log"

  require "katello::params"
  $oauth_key = $katello::params::oauth_key
  $oauth_secret = $katello::params::oauth_secret
}
