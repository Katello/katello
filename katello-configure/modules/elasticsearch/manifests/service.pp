class elasticsearch::service {
  service { "elasticsearch":
    ensure  => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => Class["elasticsearch::config"],
    before => Exec["katello_seed_db"],
    start      => '/usr/sbin/service-wait elasticsearch start',
    stop       => '/usr/sbin/service-wait elasticsearch stop',
    restart    => '/usr/sbin/service-wait elasticsearch restart',
    status     => '/usr/sbin/service-wait elasticsearch status'
  }
}
