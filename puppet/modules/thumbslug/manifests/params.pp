class thumbslug::params {
  $keystore = "/etc/candlepin/certs/keystore"
  $keystore_pass = "password"
  $oauth_secret = regsubst(generate('/usr/bin/openssl', 'rand', '-base64', '24'), '^(.{24}).*', '\1')
}
