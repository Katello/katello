class apache2::config {

  user { 'apache':
        ensure => present,
        groups => ['katello']
  }

  # support RHEL5/RHEL6 only
  file { "/etc/httpd/conf/httpd.conf":
    mode    => 0644,
    notify  => Exec["reload-apache2"];

  "/etc/httpd/conf.d":
    source  => "puppet:///modules/apache2/empty",
    ensure  => directory,
    checksum => mtime,
    # comment out the following line, as this will remove unmanaged files in conf.d directory
    # we can re-enable once pulp / katello are configured correctly
    # recurse => true, purge => true, force => true,
    mode    => 0644,
    notify  => Exec["reload-apache2"],
  }

}
