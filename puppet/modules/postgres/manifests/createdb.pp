# Create a Postgres db
define postgres::createdb($owner, $logfile) {
  sqlexec{ "createdb-$name":
    username => $postgres::params::user,
    passfile => $postgres::params::password_file,
    database => "postgres",
    sql => "CREATE DATABASE $name WITH OWNER = $owner ENCODING = 'UTF8';",
    sqlcheck => "\"SELECT datname FROM pg_database WHERE datname ='$name'\" | grep $name",
    require  => Exec["wait-for-postgresql"],
    logfile  => $logfile,
  }
}
