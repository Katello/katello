class postgres {
  Exec { logoutput => on_failure, timeout => 0 }

  include postgres::params
  include candlepin::params
  include postgres::config
  include postgres::service
}
