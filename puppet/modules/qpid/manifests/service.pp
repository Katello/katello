class qpid::service {
  service {"qpidd":
    ensure => running,
    require => Class["qpid::config"]
  }
}
