# Create a Postgres user
define postgres::createuser($passwd, $logfile) {
  exec { "createuser-$name":
    path     => "/bin:/usr/bin",
    unless   => "su - postgres -c \"psql postgres -c \\\"SELECT usename FROM pg_user WHERE usename = '${name}'\\\" | grep ${name}\" >> $logfile 2>&1",
    command  => "su - postgres -c \"yes '${passwd}' | createuser -P --createdb --no-superuser --no-createrole '${name}'; \" >> $logfile 2>&1",
    require  => Class["postgres::service"],
  }
}
