class thumbslug {
  Exec { logoutput => on_failure, timeout => 0 }

  include thumbslug::params
  include thumbslug::config
  include thumbslug::service
}
