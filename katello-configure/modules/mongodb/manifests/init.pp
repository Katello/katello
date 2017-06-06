class mongodb {
  Exec { logoutput => true, timeout => 0 }

  include mongodb::config
  include mongodb::service
}
