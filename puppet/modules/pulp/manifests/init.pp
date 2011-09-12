class pulp {
  include mongodb
  include pulp::params
  include pulp::install
  include pulp::config
  include pulp::service
}
