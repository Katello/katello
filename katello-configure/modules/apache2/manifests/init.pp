# This class installs the apache2 service
# Ensure that there is no network user called apache before installing
# this is a CentOS 5 compatable (e.g. apache 2.2) manifest.
class apache2 {
  Exec { logoutput => true, timeout => 0 }

  include apache2::params
  include apache2::config
  include apache2::service

  exec { "reload-apache2":
    # Pulp & Apache2 & Systemd are not friends - we restart rather than reload
    command     => "/sbin/service httpd restart",
    require     => Service["httpd"],
    refreshonly => true,
  }
}
