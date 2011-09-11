class pulp::params {

  $ssl_certificate_file     = "/etc/candlepin/certs/candlepin-ca.crt"
  $ssl_certificate_key_file = "/etc/candlepin/certs/candlepin-ca.key"

  require "katello::params"
  $oauth_key = $katello::params::oauth_key
  $oauth_secret = $katello::params::oauth_secret

}
