class thumbslug {
  Exec { logoutput => true, timeout => 0 }

  include thumbslug::params
  include thumbslug::config
  include thumbslug::service
}
