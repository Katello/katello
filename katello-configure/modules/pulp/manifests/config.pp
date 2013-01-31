class pulp::config {

  file {
    "/var/lib/pulp/packages":
      ensure => directory,
      owner => "apache",
      group => "apache",
      mode => 0755,
      before => Class["pulp::service"];
    "/etc/pulp/server.conf":
      content => template("pulp/etc/pulp/server.conf.erb"),
      require => File["/var/lib/pulp/packages"],
      owner   =>"apache",
      mode    =>"600",
      notify  => Exec["reload-apache2"],
      before  => [Class["apache2::service"]];
    "/etc/httpd/conf.d/pulp.conf":
      content => template("pulp/etc/httpd/conf.d/pulp.conf.erb"),
      notify  => Exec["reload-apache2"],
      before => [Class["apache2::service"]];
    "/etc/pulp/repo_auth.conf":
      content => template("pulp/etc/pulp/repo_auth.conf.erb"),
      notify  => Exec["reload-apache2"],
      before => [Class["apache2::service"]];
    "/etc/pki/pulp/content/pulp-global-repo.ca":
      ensure => link,
      target => $pulp::params::ssl_certificate_ca_file;
  }

  if $pulp::params::reset_cache == 'YES' {
    exec {"reset_pulp_cache":
      command => "rm -rf /var/lib/pulp/packages/*",
      path    => "/sbin:/bin:/usr/bin",
      before  => Exec["migrate_pulp_db"],
      require => [
        File["/var/lib/pulp/packages"],
        ],
    }
  }

  if $pulp::params::reset_data == 'YES' {
    exec {"reset_pulp_db":
      command     => "rm -f /var/lib/pulp/init.flag && service-wait httpd stop && service-wait mongod stop && rm -f /var/lib/mongodb/pulp_database*&& service-wait mongod start && rm -rf /var/lib/pulp/{distributions,published,repos}/*",
      path        => "/sbin:/usr/sbin:/bin:/usr/bin",
      before      => Exec["migrate_pulp_db"],
    }
  }

  exec {"migrate_pulp_db":
    command     => "pulp-manage-db >${katello::params::configure_log_base}/pulp_migrate.log 2>&1 && touch /var/lib/pulp/init.flag",
    creates     => "/var/lib/pulp/init.flag",
    path        => "/bin:/usr/bin",
    before      => [ Class["pulp::service"], Exec["reload-apache2"], Class["apache2::service"] ],
    notify      => Exec["reload-apache2"],
    require     => [
      File["${katello::params::configure_log_base}"],
      Class["mongodb::service"],
      File["/etc/pulp/server.conf"],
      ],
  }

  exec { "setup-crl-symlink":
    command     => "/usr/bin/openssl x509 -in '$pulp::params::ssl_certificate_file' -hash -noout | /usr/bin/xargs -I{} /bin/ln -sf '$candlepin::params::crl_file' '$pulp::params::crl_location/{}.r0'",
    subscribe   => File["/etc/candlepin/certs/candlepin-ca.crt"],
    refreshonly => true,
    before      => [ Class["pulp::service"], Exec["reload-apache2"], Class["apache2::service"] ],
    require     => Class["candlepin::config"],
  }

}
