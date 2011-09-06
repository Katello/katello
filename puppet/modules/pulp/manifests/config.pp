class pulp::config {

  # assuming sharing certificates with candlepin on the same machine
  # if certificates needs to be distributed, please fix the following.
  file {
    "/etc/pki/pulp/ca.crt":
      ensure  => link,
      target  => "/etc/candlepin/certs/candlepin-ca.crt",
      require => [Class["pulp::install"], Class["candlepin::config"]];
    "/etc/pki/pulp/ca.key":
      ensure  => link,
      target  => "/etc/candlepin/certs/candlepin-ca.key",
      require => Class["pulp::install"]
  }

  # what does this do exactly?
  exec {"initpulp":
    command   => "service pulp-server init",
    creates   => "/var/lib/pulp/init.flag",
    path      => "/sbin",
    subscribe => Package["pulp"]
  }

  exec {"setenforce":
    command => "setenforce 0",
    path    => "/usr/sbin:/bin",
    unless  => "getenforce |grep -iq disable",
    before  => Class["pulp::service"]
  }

}
