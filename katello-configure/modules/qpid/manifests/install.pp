class qpid::install {

  package {["qpid-cpp-server","qpid-cpp-client","qpid-cpp-client-ssl","qpid-cpp-server-ssl"]:
    ensure => "installed",
    before => Service["qpidd"]
  } 

  package {"policycoreutils-python":
    ensure => "installed"
  } 

  file {
    "/etc/qpid":
      require => Package["qpid-cpp-server"]
  }

}

