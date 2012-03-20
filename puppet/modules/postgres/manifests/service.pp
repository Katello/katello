class postgres::service {

  service { "postgresql":
    ensure  => running, enable => true, hasstatus => true, hasrestart => true,
    notify  => Exec['wait-for-postgresql'],
    require => Class["postgres::config"],
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
