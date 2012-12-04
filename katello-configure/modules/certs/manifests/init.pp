class certs {
  Exec { logoutput => on_failure, timeout => 0 }

  include "certs::params"
  include "certs::config"

}
