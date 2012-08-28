class apache2::install {
  package { "httpd":
    ensure => installed
  }

  package { "mod_ssl":
    ensure => present,
    require => Package["httpd"],
    notify => Service["httpd"]
  }

  Package["httpd"] -> File["/etc/httpd/conf/httpd.conf"]
  Package["httpd"] -> File["/etc/httpd/conf.d"]
  Package["httpd"] ~> Service["httpd"]
}
