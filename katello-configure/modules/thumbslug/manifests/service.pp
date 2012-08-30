class thumbslug::service {
  service {"thumbslug":
    ensure  => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => [
      Class["thumbslug::config"],
      Service["tomcat6"]
    ]
  }
}
