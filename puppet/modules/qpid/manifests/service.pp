class qpid::service {
  service {"qpidd":
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => [
      Class["qpid::config"],
      Package["qpid-cpp-server-ssl"],
      Class["certs::config"]
    ]
  }
}
