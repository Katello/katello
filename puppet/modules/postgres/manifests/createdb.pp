# Create a Postgres db
define postgres::createdb($owner) {
  sqlexec{ $name:
    password => $postgres::params::password,
    username => $postgres::params::user,
    database => "postgres",
    sql => "CREATE DATABASE $name WITH OWNER = $owner ENCODING = 'UTF8';",
    sqlcheck => "\"SELECT datname FROM pg_database WHERE datname ='$name'\" | grep $name",
    require  => Class["postgres::service"],
  }
}
