class katello::config::files {

  include katello::params

  # this should be required by all classes that need to log there (one of these)
  file {
    "${katello::params::log_base}":
      owner   => $katello::params::user,
      group   => $katello::params::group,
      mode    => 750;
    # this is a symlink when called via katello-configure
    "${katello::params::configure_log_base}":
      owner   => $katello::params::user,
      group   => $katello::params::group,
      mode    => 750;
  }

  # create Rails logs in advance to get correct owners and permissions
  file {[
    "${katello::params::log_base}/production.log",
    "${katello::params::log_base}/production_sql.log",
    "${katello::params::log_base}/production_delayed_jobs.log",
    "${katello::params::log_base}/production_delayed_jobs_sql.log",
    "${katello::params::log_base}/production_orch.log",
    "${katello::params::log_base}/production_delayed_jobs_orch.log"]:
      owner   => $katello::params::user,
      group   => $katello::params::group,
      content => "",
      replace => false,
      mode    => 640,
  }

  file {
    "${katello::params::config_dir}/thin.yml":
      content => template("katello/${katello::params::config_dir}/thin.yml.erb"),
      owner   => "root",
      group   => "root",
      mode    => "644";

    "${katello::params::config_dir}/katello.yml":
      content => template("katello/${katello::params::config_dir}/katello.yml.erb"),
      owner   => $katello::params::user,
      group   => $katello::params::group,
      mode    => "600";

    "/etc/sysconfig/katello":
      content => template("katello/etc/sysconfig/katello.erb"),
      owner   => "root",
      group   => "root",
      mode    => "644";

    "/etc/katello/client.conf":
      content => template("katello/etc/katello/client.conf.erb"),
      owner   => "root",
      group   => "root",
      mode    => "644";

    "/etc/httpd/conf.d/katello.conf":
      content => template("katello/etc/httpd/conf.d/katello.conf.erb"),
      owner   => "root",
      group   => "root",
      mode    => "644";

    "/etc/httpd/conf.d/katello.d/katello.conf":
      content => template("katello/etc/httpd/conf.d/katello.d/katello.conf.erb"),
      owner   => "root",
      group   => "root",
      mode    => "644";

    "/etc/ldap_fluff.yml":
      content => template("katello/etc/ldap_fluff.yml.erb"),
      owner   => $katello::params::user,
      group   => $katello::params::group,
      mode    => "600";
  }

}