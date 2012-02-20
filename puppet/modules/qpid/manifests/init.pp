class qpid {
  include qpid::install
  include qpid::config
  include qpid::service
  include certs::params
}
