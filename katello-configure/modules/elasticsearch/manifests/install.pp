class elasticsearch::install {
  package {["elasticsearch", "rubygem-tire"]:
    ensure => "installed"
  } 
}

