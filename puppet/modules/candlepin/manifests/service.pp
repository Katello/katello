class candlepin::service {
  service {"tomcat6":
    ensure  => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => [ Class["candlepin::config"], Class["postgres::service"] ]
  }

  exec { "cpinit":
    # tomcat startup is slow - try multiple times
    command => "/usr/bin/wget --timeout=30 --tries=5 --retry-connrefused --qO- http://localhost:8080/candlepin/admin/init && touch /var/lib/katello/cpinit_done",
    require => Service["tomcat6"],
    creates => "/var/lib/katello/cpinit_done",
    before  => Class["apache2::service"]
  }
}
