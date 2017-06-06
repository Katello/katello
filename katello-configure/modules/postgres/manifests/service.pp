class postgres::service {

  # never require Service["postgresql"] but Class["postgres::service"] or Exec["wait-for-postgresql"]
  service { "postgresql":
    ensure  => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    start      => '/usr/sbin/service-wait postgresql start',
    stop       => '/usr/sbin/service-wait postgresql stop',
    restart    => '/usr/sbin/service-wait postgresql restart',
    status     => '/usr/sbin/service-wait postgresql status',
    require => [Class["postgres::config"]],
  }

}
