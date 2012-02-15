class pulp {
  include mongodb
  include pulp::params
  include candlepin::params
  include pulp::config
  include pulp::service
}
