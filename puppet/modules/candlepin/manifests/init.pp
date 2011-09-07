class candlepin {
  include postgres
  include candlepin::params
  include candlepin::install
  include candlepin::config
  include candlepin::service
}
