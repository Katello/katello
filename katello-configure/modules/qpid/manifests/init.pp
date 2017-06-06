class qpid {
  Exec { logoutput => true, timeout => 0 }

  include certs::params
  include qpid::install
  include qpid::config
  include qpid::service
}
