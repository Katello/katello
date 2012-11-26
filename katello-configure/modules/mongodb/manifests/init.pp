class mongodb {
  Exec { logoutput => on_failure, timeout => 0 }

  include mongodb::config
  include mongodb::service
}
