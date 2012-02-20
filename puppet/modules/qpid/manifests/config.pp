class qpid::config {

  exec { "add-qpidd-user-to-katello-group":
        command => "usermod -a -G katello qpidd",
        path => "/usr/sbin",
        before => [Class["qpid::service"]],
  }

  file { "/etc/qpidd.conf":
    content => template("qpid/etc/qpidd.conf.erb"),
    before => [Class["qpid::service"]],
    notify => Service["qpidd"]
  }
  
}
