class pulp::config {

  # assuming sharing certificates with candlepin on the same machine
  # if certificates needs to be distributed, please fix the following.
  file {
    "/var/lib/pulp/packages":
      ensure => directory,
      owner => "apache", group => "apache", mode => 0755,
      before => Class["pulp::service"];
    "/etc/pulp/pulp.conf":
      content => template("pulp/etc/pulp/pulp.conf.erb"),
      require => File["/var/lib/pulp/packages"],
      owner=>"apache",
      mode=>"600",
      before => [Class["apache2::service"]];
    "/etc/httpd/conf.d/pulp.conf":
      content => template("pulp/etc/httpd/conf.d/pulp.conf.erb"),
      before => [Class["apache2::service"]];
    "/etc/pulp/repo_auth.conf":
      content => template("pulp/etc/pulp/repo_auth.conf.erb"),
      before => [Class["apache2::service"]];
    "/etc/pki/pulp/content/pulp-global-repo.ca":
      ensure => link,
      target => $pulp::params::ssl_certificate_ca_file;
  }

  exec {"migrate_pulp_db":
    # we need to give some time to mongo to start sockets (RHBZ 824405)
    command     => "sleep 5 && pulp-migrate >${katello::params::log_base}/katello-configure/pulp_migrate.log 2>&1 && touch /var/lib/pulp/init.flag",
    creates     => "/var/lib/pulp/init.flag",
    path        => "/bin:/usr/bin",
    before      => Class["pulp::service"],
    require     => [Class["mongodb::service"], File["/etc/pulp/pulp.conf"]],
  }

  exec { "set candlepin crl file":
      command =>  "/usr/bin/openssl x509 -in '$pulp::params::ssl_certificate_file' -hash -noout | /usr/bin/xargs -I{} /bin/ln -sf '$candlepin::params::crl_file' '$pulp::params::crl_location/{}.r0'",
      require => Class["candlepin::config"],
  }

}
