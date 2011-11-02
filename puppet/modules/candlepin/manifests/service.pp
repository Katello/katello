class candlepin::service {
  service {"tomcat6":
    ensure  => running, enable => true, hasstatus => true, hasrestart => true,
    require => Class["candlepin::config"]
  }
}
