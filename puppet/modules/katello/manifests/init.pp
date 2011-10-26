class katello {
  
  # Headpin does not care about pulp
  case $deployment {
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
  include katello::params
  include katello::config
  include katello::service
}
