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
}
