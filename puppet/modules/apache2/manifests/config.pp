class apache2::config {

  group { $apache2::params::group: ensure => present, require => Class["apache2::install"] }
  user  { $apache2::params::user:
  ensure => present, home => $apache2::params::home,
    managehome => false, membership => minimum, groups => [],
    shell => "/sbin/nologin", require => Package["httpd"],
  }

  # support RHEL5/RHEL6 only
  file{
    "/etc/httpd/conf/httpd.conf":
      source  => ["puppet:///apache2/etc/httpd/conf/httpd.conf.${lsbmajdistrelease}","puppet:///apache2/etc/httpd/conf/httpd.conf.6"],
      mode    => 0644,
      notify  => Exec["reload-apache2"],
      require => Package["httpd"];
#ensure that only managed apache file are present - commented out by default
    "/etc/httpd/conf.d":
      source  => "puppet:///apache2/empty",
      ensure  => directory, checksum => mtime,
      # comment out the following line, as this will remove unmanaged files in conf.d directory
      # we can re-enable once pulp / katello are configured correctly
      # recurse => true, purge => true, force => true,
      mode    => 0644,
      notify  => Exec["reload-apache2"],
      require => Package["httpd"]
  }

}
