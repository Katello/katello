# Create a Postgres user
define postgres::createuser($passwd, $roles = "") {
  sqlexec{ "createuser-$name":
    password => $postgres::params::password,
    username => $postgres::params::user,
    database => "postgres",
    sql      => "CREATE ROLE ${name} WITH LOGIN PASSWORD '${passwd}' ${roles};",
    sqlcheck => "\"SELECT usename FROM pg_user WHERE usename = '${name}'\" | grep ${name}",
    require  => Class["postgres::service"],
  }

}

