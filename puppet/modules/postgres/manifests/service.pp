class postgres::service {

  service { "postgresql":
    ensure => running,
    enable => true,
    hasstatus => true,
    require => Class["postgres::config"],
  }
}
