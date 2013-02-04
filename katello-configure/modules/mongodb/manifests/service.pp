class mongodb::service {
  service {"mongod":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    start      => '/usr/sbin/service-wait mongod start',
    stop       => '/usr/sbin/service-wait mongod stop',
    restart    => '/usr/sbin/service-wait mongod restart',
    status     => '/usr/bin/wget --timeout=30 --tries=5 --retry-connrefused -qO- http://localhost:27017/',
    require    => Class["mongodb::config"]
  }
}
