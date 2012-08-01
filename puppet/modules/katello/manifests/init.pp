class katello {
  include katello::params
  include certs
  # Headpin does not care about pulp
  case $katello::params::deployment {
    'katello': {
      include pulp
    }
    'headpin' : {
      include apache2
      include thumbslug
    }
    default : {}
  }
  include apache2
  include candlepin
  include elasticsearch
  include katello::config
  include katello::service
}
