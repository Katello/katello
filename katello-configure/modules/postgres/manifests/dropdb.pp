# Drop a Postgres db
define postgres::dropdb($logfile, $refreshonly = false) {
  sqlexec{ "dropdb-$name":
    username    => $postgres::params::user,
    passfile    => $postgres::params::password_file,
    database    => "postgres",
    sql         => "DROP DATABASE $name;",
    require     => Exec["wait-for-postgresql"],
    logfile     => $logfile,
    refreshonly => $refreshonly,
  }
}
