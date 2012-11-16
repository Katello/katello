class candlepin::service {
  service {"tomcat6":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    start      => '/usr/sbin/service-wait tomcat6 start',
    stop       => '/usr/sbin/service-wait tomcat6 stop',
    restart    => '/usr/sbin/service-wait tomcat6 restart',
    status     => '/usr/sbin/service-wait tomcat6 status',
    require    => [
      Class["candlepin::config"],
      Class["postgres::service"],
      File[$certs::params::katello_keystore],
      File["/usr/share/tomcat6/conf/keystore"],
      File["${certs::params::candlepin_certs_dir}/candlepin-upstream-ca.crt"]
    ]
  }

  exec { "cpinit":
    # tomcat startup is slow - try multiple times (the initialization service is idempotent)
    command => "/usr/bin/wget --timeout=30 --tries=5 --retry-connrefused -qO- http://localhost:8080/candlepin/admin/init >${katello::params::configure_log_base}/cpinit.log 2>&1 && touch /var/lib/katello/cpinit_done",
    require => [ Service["tomcat6"], File["${katello::params::configure_log_base}"] ],
    creates => "/var/lib/katello/cpinit_done",
    before  => Class["apache2::service"],
  }
}
