class katello::service {
  service {["katello", "katello-jobs"]:
    ensure    => running,
    enable    => true,
    hasstatus => true,
    before    => Class["apache2::service"],
    require   => [Class["katello::config"],Class["candlepin::service"], Class["pulp::service"], Class["apache2::config"]]
  }

}
