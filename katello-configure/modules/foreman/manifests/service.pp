class foreman::service {
  service {'foreman':
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
  }
}
