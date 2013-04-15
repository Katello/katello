class signo::service {
  case $operatingsystem {
    fedora: { $provider = "systemd" }
    default: { $provider = "redhat" }
  }

  service {"signo":
    ensure  => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    notify  => Exec["reload-apache2"],
    provider => $provider
  }
}
