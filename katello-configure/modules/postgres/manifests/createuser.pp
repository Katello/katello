# Create a Postgres user
define postgres::createuser($passwd, $roles = "", $logfile) {
  sqlexec{ "createuser-$name":
    username => $postgres::params::user,
    passfile => $postgres::params::password_file,
    database => "postgres",
    sql      => "CREATE ROLE ${name} WITH LOGIN PASSWORD '${passwd}' ${roles};",
    sqlcheck => "\"SELECT usename FROM pg_user WHERE usename = '${name}'\" | grep ${name}",
    require  => Exec["wait-for-postgresql"],
    logfile  => $logfile,
  }
}
