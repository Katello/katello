class katello {
  include pulp
  include candlepin
  include katello::params
  include katello::config
  include katello::service
}
