class elasticsearch::service {
  service { "elasticsearch":
    ensure  => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => Class["elasticsearch::config"],
    before => Exec["katello_seed_db"]
  }
}
