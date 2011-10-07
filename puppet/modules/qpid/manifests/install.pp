class qpid::install {
  package {["qpid-cpp-server","qpid-cpp-client"]:
    ensure => "installed"
  } 

  file {
    "/etc/qpid":
      require => Package["qpid-cpp-server"];
  }
  Package["qpid-cpp-server"] -> Service["qpidd"]
}

