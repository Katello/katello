# Base SQL exec
define sqlexec($username, $passfile, $database, $sql, $sqlcheck, $logfile) {
 exec{ "psql -h localhost --username=${username} $database -c \"${sql}\" >> $logfile 2>&1":
    environment => $passfile? {
      "NONE" => undef,
      default => "PGPASSFILE=${passfile}"
    },
    path        => $path,
    timeout     => 600,
    unless      => "psql -U $username $database -c $sqlcheck",
    require     => Exec["wait-for-postgresql"],
  }
}
