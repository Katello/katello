class postgres {
  include postgres::params
  include candlepin::params
  include postgres::config
  include postgres::service
}
