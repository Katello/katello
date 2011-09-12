class mongodb::service {
  service {"mongod":
    ensure  => running, enable => true, hasstatus => true, hasrestart => true,
    require => Class["mongodb::config"]
  }
}
