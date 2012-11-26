class mongodb::config {

  file {
    "/var/lib/mongodb/journal":
      ensure => 'directory',
      owner  => 'mongodb',
      group  => 'mongodb',
      mode   => 755,
      before  => Class["mongodb::service"];
    "/etc/mongodb.conf":
      content => template("mongodb/mongodb.conf.erb"),
      owner  => 'root',
      group  => 'root',
      mode   => 644,
      notify  => Service["mongod"],
      before  => Class["mongodb::service"];
  }

  exec {"mongo-journal-prealloc":
    command => "/bin/dd if=/dev/zero of=/var/lib/mongodb/journal/prealloc.0 bs=1M count=1K && /bin/dd if=/dev/zero of=/var/lib/mongodb/journal/prealloc.1 bs=1M count=1K && /bin/dd if=/dev/zero of=/var/lib/mongodb/journal/prealloc.2 bs=1M count=1K && chmod 600 /var/lib/mongodb/journal/prealloc* && chown mongodb:mongodb /var/lib/mongodb/journal/prealloc*",
    require => File["/var/lib/mongodb/journal"],
    # after mongo has started it renames prealloc.0 to j._0
    creates => "/var/lib/mongodb/journal/j._0",
    before  => Class["mongodb::service"],
  }
}
