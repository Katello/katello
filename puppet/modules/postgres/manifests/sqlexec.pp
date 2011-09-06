# Base SQL exec
define sqlexec($username, $password, $database, $sql, $sqlcheck) {
 exec{ "psql -h localhost --username=${username} $database -c \"${sql}\" >> ${postgres::params::sql_log} 2>&1":
    environment => $password ? {
      "" => undef,
      default => "PGPASSWORD=${password}"
    },
    path        => $path,
    timeout     => 600,
    unless      => "psql -U $username $database -c $sqlcheck",
    require     => Class["postgres::service"],
  }
}
