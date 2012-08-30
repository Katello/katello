class thumbslug::params {

  $keystore = "/etc/pki/katello/keystore"
  $oauth_secret = katello_create_read_password(katello_config_value('oauth_token_file'))
  
}
