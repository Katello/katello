class candlepin::service {
  service {"tomcat6":
    ensure => running,
    require => Class["candlepin::config"]
  }
}
