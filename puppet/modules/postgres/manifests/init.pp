class postgres {
  include postgres::params
  include postgres::install
  include postgres::config
  include postgres::service
}
