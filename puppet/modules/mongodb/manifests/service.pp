class mongodb::service {
  service {"mongod":
    ensure => running,
    require => Class["mongodb::config"]
  }
}
