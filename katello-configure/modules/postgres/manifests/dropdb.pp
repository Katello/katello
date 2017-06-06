# Drop a Postgres db
define postgres::dropdb($logfile, $refreshonly = false) {
  exec{ "dropdb-$name":
    path        => "/bin:/usr/bin",
    command     => "su - postgres -c 'dropdb $name' >> $logfile 2>&1",
    returns     => [0, 1],
    require     => Class["postgres::service"],
    refreshonly => $refreshonly,
  }
}
