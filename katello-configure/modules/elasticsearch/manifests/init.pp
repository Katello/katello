class elasticsearch {
  Exec { logoutput => true, timeout => 0 }

  include elasticsearch::params
  include elasticsearch::config
  include elasticsearch::service
}
