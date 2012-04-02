class thumbslug::params {

  $keystore = "/etc/pki/katello/keystore"
  $oauth_secret = regsubst(generate('/usr/bin/openssl', 'rand', '-base64', '24'), '^(.{24}).*', '\1')
  
}
