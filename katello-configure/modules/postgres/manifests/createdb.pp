# Create a Postgres db
define postgres::createdb($owner, $logfile) {
  exec{ "createdb-$name":
    path     => "/bin:/usr/bin",
    unless   => "su - postgres -c \"psql postgres -c \\\"SELECT datname FROM pg_database WHERE datname = '${name}'\\\" | grep ${name} \" >> $logfile 2>&1",
    command  => "su - postgres -c \"createdb --owner=$owner --encoding=UTF8 '$name' \" >> $logfile 2>&1",
    require  => Class["postgres::service"],
  }
}
