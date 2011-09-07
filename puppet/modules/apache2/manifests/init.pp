# This class installs the apache2 service
# Ensure that there is no network user called apache before installing
# this is a CentOS 5 compatable (e.g. apache 2.2) manifest.
class apache2 {
  include apache2::params
  include apache2::install
  include apache2::config
  include apache2::service

  exec { "reload-apache2":
    command     => "/etc/init.d/httpd reload",
    onlyif      => "/usr/sbin/apachectl -t",
    require     => Service["httpd"],
    refreshonly => true,
  }

}
