class candlepin {
  include postgres
  include candlepin::params
  include candlepin::config
  include candlepin::service
  include certs::params
}
