class postgres {
  Exec { logoutput => true, timeout => 0 }

  include postgres::params
  include candlepin::params
  include postgres::config
  include postgres::service
}
