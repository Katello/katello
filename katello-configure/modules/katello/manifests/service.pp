class katello::service {
  service {"katello":
    ensure  => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => $katello::params::deployment ? {
                'katello' =>  [Class["katello::config"],Class["candlepin::service"], Class["pulp::service"], Class["apache2::config"]],
                'headpin' =>  [Class["katello::config"],Class["candlepin::service"], Class["thumbslug::service"], Class["apache2::config"]],
                default => []
    },
    notify  => Exec["reload-apache2"];
  }

  service {"katello-jobs":
    ensure  => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    require => Service["katello"]
  }
}
