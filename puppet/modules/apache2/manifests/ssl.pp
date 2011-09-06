class apache2::ssl {
  include apache2
  package { [ "mod_ssl" , "mod_authz_ldap" ]:
    ensure => present, require => Package["httpd"],
    notify => Service["httpd"]
  }
  file {
    "/etc/httpd/conf.d/ssl.conf":
      source => "puppet:///modules/apache2/etc/httpd/conf.d/ssl.conf",
      mode => 0644, owner => root, group => root,
      notify => Exec["reload-apache2"];
    ["/var/cache/mod_ssl", "/var/cache/mod_ssl/scache"]:
      ensure => directory,
      owner => apache, group => root, mode => 0750,
      notify => Service["httpd"];
  }
}
