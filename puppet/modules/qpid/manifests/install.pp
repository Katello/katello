class qpid::install {
  package {["qpid-cpp-server","qpid-cpp-client"]:
    ensure => "installed"
  } 
}

