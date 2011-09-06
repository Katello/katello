class candlepin::service {
  service {"tomcat6":
    ensure => running
  }
}
