class qpid {
  include certs::params
  include qpid::install
  include qpid::config
  include qpid::service
}
