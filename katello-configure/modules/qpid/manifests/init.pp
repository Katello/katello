class qpid {
  Exec { logoutput => on_failure, timeout => 0 }

  include certs::params
  include qpid::install
  include qpid::config
  include qpid::service
}
