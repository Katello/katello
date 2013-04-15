class mongodb::service {
  service {"mongod":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    start      => '/usr/sbin/service-wait mongod start',
    stop       => '/usr/sbin/service-wait mongod stop',
    restart    => '/usr/sbin/service-wait mongod restart',
    status     => '/usr/bin/wget --tries=30 --wait=2 --retry-connrefused -qO- http://localhost:27017/ --waitretry=0',
    require    => Class["mongodb::config"]
  }
}
