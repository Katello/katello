class elasticsearch {
  Exec { logoutput => on_failure, timeout => 0 }

  include elasticsearch::params
  include elasticsearch::config
  include elasticsearch::service
}
