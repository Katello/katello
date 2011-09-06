class katello::service {
  service {["katello", "katello-jobs"]:
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Class["katello::config"]
  }

}
