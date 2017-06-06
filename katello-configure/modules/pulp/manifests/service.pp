class pulp::service {
  include apache2::ssl
  include mongodb
  include qpid

  # we dont really want to run the pulp-server init.d
  # it restarts other daemons that we manage via puppet too
  # this simply acts as a synchronization point
  service {"pulp-server":
    ensure    => stopped,
    enable    => false,
    hasstatus => false,
    require   => [
      Class["pulp::config"],
      Class["mongodb::service"],
      Class["qpid::service"],
      Class["apache2::service"]
      ],
  }
}
