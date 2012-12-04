class foreman::service {
  service {'foreman':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    start      => '/usr/sbin/service-wait foreman start',
    stop       => '/usr/sbin/service-wait foreman stop',
    restart    => '/usr/sbin/service-wait foreman restart',
    status     => '/usr/sbin/service-wait foreman status',
  }
}
