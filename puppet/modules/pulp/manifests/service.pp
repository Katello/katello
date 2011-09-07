class pulp::service {
  include apache2::ssl

  service {"pulp-server":
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Class["pulp::config"],
    before    => Class["apache2::service"],
  }

}
