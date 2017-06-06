class certs {
  Exec { logoutput => true, timeout => 0 }

  include "certs::params"
  include "certs::config"

}
