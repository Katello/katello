class mongodb::config {

  # preallocate journal files for MongoDB 2.0+ (Fedora 16+)
  exec {"mongo-journal-prealloc":
    command => "/bin/dd if=/dev/zero of=/var/lib/mongodb/journal/prealloc.0 bs=1M count=1K && /bin/dd if=/dev/zero of=/var/lib/mongodb/journal/prealloc.1 bs=1M count=1K && /bin/dd if=/dev/zero of=/var/lib/mongodb/journal/prealloc.2 bs=1M count=1K && chmod 600 /var/lib/mongodb/journal/prealloc* && chown mongodb:mongodb /var/lib/mongodb/journal/prealloc*",
    onlyif => "/usr/bin/test -d /var/lib/mongodb/journal", # journal dir is present only in MongoDB 2.0+
    creates => "/var/lib/mongodb/journal/j._0",
    before  => Class["mongodb::service"]
  }
}
