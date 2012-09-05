class mongodb::install {
  package {["mongodb-server","mongodb"]:
    ensure => "installed"
  } 
  file {
    "/etc/mongodb.conf":
      require => Package["mongodb-server"];
    "/var/lib/mongodb":
      ensure  => directory,
      mode    => 644,
      owner   => "mongodb",
      group   => "root",
      require => Package["mongodb-server"];
  }
}

