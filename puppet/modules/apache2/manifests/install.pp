class apache2::install {
  package { "httpd": ensure => installed}
  package { [ "mod_ssl" ]:
    ensure => present, require => Package["httpd"],
    notify => Service["httpd"]
  }
  group { $apache2::params::group: ensure => present }
  user  { $apache2::params::user:
  ensure => present, home => $apache2::params::home,
    managehome => false, membership => minimum, groups => [],
    shell => "/sbin/nologin", require => Package["httpd"],
  }
  Package["httpd"] -> File["/etc/httpd/conf/httpd.conf"]
  Package["httpd"] -> File["/etc/httpd/conf.d"]
  Package["httpd"] ~> Service["httpd"]
}
