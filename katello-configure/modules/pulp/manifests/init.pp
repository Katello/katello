class pulp {
  Exec { logoutput => on_failure, timeout => 0 }

  include mongodb
  include pulp::params
  include candlepin::params
  include pulp::config
  include pulp::service
}
