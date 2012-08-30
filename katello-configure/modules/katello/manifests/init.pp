class katello {
  include katello::params
  include certs
  include apache2
  # Headpin does not care about pulp
  case $katello::params::deployment {
    'katello': {
      include pulp
      if $katello::params::use_foreman {
        class { 'foreman':
          install            => $katello::params::install_foreman,
          thin_ip            => "127.0.0.1",
          thin_start_port    => $katello::params::foreman_start_port,
          thin_process_count => $katello::params::foreman_process_count,
          configure_log_base => $katello::params::configure_log_base,
        }
      }
    }
    'headpin' : {
      include apache2
      include thumbslug
    }
    default : {}
  }
  include candlepin
  include elasticsearch
  include katello::config
  include katello::service
}
