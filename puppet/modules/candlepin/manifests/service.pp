class candlepin::service {
  service {"tomcat6":
    ensure  => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => Class["candlepin::config"]
  }

  exec {"wait for candlepin":
    require => Service["tomcat6"],
    command => "/usr/bin/wget --spider --tries 10 --retry-connrefused --no-check-certificate https://localhost:8443/candlepin/";
  }
}
