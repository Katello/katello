class signo::install {
  package {["signo", "signo-katello"]:
    ensure => installed
  }
}