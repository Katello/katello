class mongodb::install {
  package {["mongodb-server","mongodb"]:
    ensure => "installed"
  } 
}

