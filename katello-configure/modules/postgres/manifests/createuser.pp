# Create a Postgres user
define postgres::createuser($passwd, $logfile) {
  exec { "createuser-$name":
    path     => "/bin:/usr/bin",
    command  => "su - postgres -c \"psql -a postgres -c \\\"SELECT usename FROM pg_user WHERE usename = '${name}'\\\" | grep ${name} || ( yes '${passwd}' | createuser -P --createdb --no-superuser --no-createrole '${name}'; )\" >> $logfile 2>&1",
    require  => Class["postgres::service"],
  }
}
