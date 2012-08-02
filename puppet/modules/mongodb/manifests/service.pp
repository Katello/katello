class mongodb::service {
  service {"mongod":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    start      => '/usr/sbin/service-wait mongod start',
    stop       => '/usr/sbin/service-wait mongod stop',
    restart    => '/usr/sbin/service-wait mongod restart',
    status     => '/usr/sbin/service-wait mongod status',
    require    => Class["mongodb::config"]
  }
}
