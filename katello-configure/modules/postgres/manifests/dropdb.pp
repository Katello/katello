# Drop a Postgres db
define postgres::dropdb($logfile, $refreshonly = false) {
  sqlexec{ "dropdb-$name":
    username    => $postgres::params::user,
    passfile    => $postgres::params::password_file,
    database    => "postgres",
    sql         => "DROP DATABASE $name;",
    require     => Class["postgres::service"],
    logfile     => $logfile,
    refreshonly => $refreshonly,
  }
}
