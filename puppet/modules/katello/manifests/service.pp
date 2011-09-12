class katello::service {
  service {["katello", "katello-jobs"]:
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => [Class["katello::config"],Class["candlepin::service"], Class["pulp::service"], Class["apache2::config"]],
    notify   => Exec["reload-apache2"];
  }

}
