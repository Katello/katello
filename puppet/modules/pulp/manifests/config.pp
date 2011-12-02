class pulp::config {

  # assuming sharing certificates with candlepin on the same machine
  # if certificates needs to be distributed, please fix the following.
  file {
    "/etc/pulp/pulp.conf":
      content => template("pulp/etc/pulp/pulp.conf.erb"),
      before => [Class["apache2::service"]];
    "/etc/pulp/repo_auth.conf":
      content => template("pulp/etc/pulp/repo_auth.conf.erb"),
      before => [Class["apache2::service"]];
    "/etc/pki/content/pulp-global-repo.ca":
      ensure => link,
      target => $pulp::params::ssl_certificate_ca_file;
  }

  exec {"migrate_pulp_db":
    command     => "pulp-migrate && touch /var/lib/pulp/init.flag",
    creates     => "/var/lib/pulp/init.flag",
    path        => "/bin:/usr/bin",
    before      => Class["pulp::service"],
    require     => [Class["mongodb::service"], File["/etc/pulp/pulp.conf"]],
  }

  exec { "set candlepin crl file":
      command =>  "/usr/bin/openssl x509 -in '$pulp::params::ssl_certificate_file' -hash -noout | /usr/bin/xargs -I{} /bin/ln -s '$candlepin::params::crl_file' '$pulp::params::crl_location/{}.r0'",
      require => Class["candlepin::config"],
  }

  # disable SELinux
  exec {"setenforce":
    command => "setenforce 0",
    path    => "/usr/sbin:/bin",
    unless  => "getenforce |egrep -iq 'disable|Permissive'",
    before  => [Class["pulp::service"], Exec["migrate_pulp_db"]],
  }

  augeas {"disable_selinux":
    context => "/files/etc/sysconfig/selinux",
    changes => ["set SELINUX permissive"],
    before  => [Class["pulp::service"], Exec["migrate_pulp_db"]],
  }

}
