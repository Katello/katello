class thumbslug::config {

  user { 'thumbslug':
        ensure => present,
        groups => ['katello']
  }

  file { "/etc/thumbslug/thumbslug.conf":
    content => template("thumbslug/etc/thumbslug/thumbslug.conf.erb"),
    require => Class["certs::config"],
    notify  => Service["thumbslug"];
  }

  # copy candlepin cert to thumbslug dir
  # required as of thumbslug-0.27
  file { "/etc/thumbslug/client-ca.pem":
    source => "/etc/candlepin/certs/candlepin-ca.crt",
    require => [Class["certs::config"]],
    notify => Service["thumbslug"];
  }
}
