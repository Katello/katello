class pulp::config {

  file {
    "/var/lib/pulp/packages":
      ensure => directory,
      owner => "apache",
      group => "apache",
      mode => 0755,
      before => Class["pulp::service"];
    "/etc/pulp/pulp.conf":
      content => template("pulp/etc/pulp/pulp.conf.erb"),
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

  exec {"migrate_pulp_db":
    # we need to give some time to mongo to start sockets (RHBZ 824405)
    command     => "sleep 5 && pulp-migrate >${katello::params::configure_log_base}/pulp_migrate.log 2>&1 && touch /var/lib/pulp/init.flag",
    creates     => "/var/lib/pulp/init.flag",
    path        => "/bin:/usr/bin",
    before      => Class["pulp::service"],
    require     => [
      File["${katello::params::configure_log_base}"],
      Class["mongodb::service"],
      File["/etc/pulp/pulp.conf"],
      ],
  }

  exec { "setup-crl-symlink":
    command     => "/usr/bin/openssl x509 -in '$pulp::params::ssl_certificate_file' -hash -noout | /usr/bin/xargs -I{} /bin/ln -sf '$candlepin::params::crl_file' '$pulp::params::crl_location/{}.r0'",
    subscribe   => File["/etc/candlepin/certs/candlepin-ca.crt"],
    refreshonly => true,
    require     => Class["candlepin::config"],
  }

}
