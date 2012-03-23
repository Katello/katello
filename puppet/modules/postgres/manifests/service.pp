class postgres::service {

  # RHBZ 800534 for RHEL 6.x - pg sysvinit script return non-zero when PID is not created in 2 seconds
  exec { "fix-pgsysvinit":
    path        => "/usr/bin:/bin",
    onlyif      => "grep '\"x\$pid\" != x' /etc/init.d/postgresql",
    command     => "sed -i 's/\"x\$pid\" != x/1 = 1/g' /etc/init.d/postgresql"
  }

  service { "postgresql":
    ensure  => running, enable => true, hasstatus => true, hasrestart => true,
    notify  => Exec['wait-for-postgresql'],
    require => [Exec['fix-pgsysvinit'], Class["postgres::config"]],
  }

  # wait 30 seconds for postgresql daemon to accept connections and execute SQL commands or timeout when not running
  exec { "wait-for-postgresql":
    environment => "PGCONNECT_TIMEOUT=5",
    path        => "/usr/bin:/bin",
    command     => "bash -c \"for i in {1..7}; do psql -U ${postgres::params::user} -h localhost -c 'select count(*) from pg_tables' >/dev/null 2>&1 || sleep 5; done\"",
    timeout     => 30, # loop above is for 35 secs max but we timeout after 30
    user        => $postgres::params::user,
    refreshonly => true
  }

}
