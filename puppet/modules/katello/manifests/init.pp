class katello {

  include katello::params
  # Headpin does not care about pulp
  case $katello::params::deployment {
      'katello': {
        include pulp
      }
      'headpin' : {
        include apache2
      }
      default : {}
  }

  include apache2
  include candlepin
  include katello::config
  include katello::service
}
