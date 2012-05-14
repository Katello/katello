class apache2::config {

  exec { "add-apache-user-to-katello-group":
        command => "usermod -a -G katello apache",
        path => "/usr/sbin"
  }

  # support RHEL5/RHEL6 only
  file{
    "/etc/httpd/conf/httpd.conf":
    # does not force config file for now until we sort out our vhost layout
    #  source  => ["puppet:///modules/apache2/etc/httpd/conf/httpd.conf.${lsbmajdistrelease}","puppet:///apache2/etc/httpd/conf/httpd.conf.6"],
      mode    => 0644,
      notify  => Exec["reload-apache2"];
#ensure that only managed apache file are present - commented out by default
    "/etc/httpd/conf.d":
      source  => "puppet:///modules/apache2/empty",
      ensure  => directory, checksum => mtime,
      # comment out the following line, as this will remove unmanaged files in conf.d directory
      # we can re-enable once pulp / katello are configured correctly
      # recurse => true, purge => true, force => true,
      mode    => 0644,
      notify  => Exec["reload-apache2"],
  }

}
