class pulp {
  Exec { logoutput => true, timeout => 0 }

  include mongodb
  include pulp::params
  include candlepin::params
  include pulp::config
  include pulp::service
}
