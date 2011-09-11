class qpid::config {
  
  file {
    "/etc/qpid":
      require => Class["qpid::install"];
  }

}
