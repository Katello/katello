class mongodb::config {
  
  file {
    "/etc/mongodb.conf":
      require => Class["mongodb::install"];
    "/var/lib/mongodb":
      ensure => directory,
      owner => "mongodb",
      group => "root",
      require => Class["mongodb::install"];
  }

}
