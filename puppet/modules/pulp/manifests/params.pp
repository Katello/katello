class pulp::params {

  $ssl_certificate_file     = "/etc/candlepin/certs/candlepin-ca.crt"
  $ssl_certificate_key_file = "/etc/candlepin/certs/candlepin-ca.key"
  $ssl_certificate_ca_file  = $ssl_certificate_file

  $repo_auth = true

  #repos
  $cert_location               = "/etc/pki/content"
  $global_cert_location        = $cert_location
  $protected_repo_listing_file = "${cert_location}/pulp-protected-repos"
  #crl
  $crl_location                = $cert_location

  require "katello::params"
  $oauth_key = $katello::params::oauth_key
  $oauth_secret = $katello::params::oauth_secret

}
