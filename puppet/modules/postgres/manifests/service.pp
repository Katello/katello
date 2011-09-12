class postgres::service {

  service { "postgresql":
    ensure  => running, enable => true, hasstatus => true, hasrestart => true,
    require => Class["postgres::config"],
  }
}
