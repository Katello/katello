class foreman::install {
  package {'foreman-postgresql':
    ensure  => present,
    before => Class['foreman::service']
  }
}
