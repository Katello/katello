class qpid::config {

  user { 'qpidd':
        ensure => present,
        groups => ['katello']
  }

  file { "/etc/qpidd.conf":
    content => template("qpid/etc/qpidd.conf.erb"),
    before => [Class["qpid::service"]],
    notify => Service["qpidd"]
  }
  
}
