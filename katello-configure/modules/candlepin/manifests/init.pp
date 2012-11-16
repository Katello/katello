class candlepin {
  Exec { logoutput => on_failure, timeout => 0 }

  include postgres
  include candlepin::params
  include candlepin::config
  include candlepin::service
  include certs::params
}
