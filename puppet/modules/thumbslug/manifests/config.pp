class thumbslug::config {

  exec { "add-thumbslug-user-to-katello-group":
        command => "usermod -a -G katello thumbslug",
        path => "/usr/sbin"
  }

  file { "/etc/thumbslug/thumbslug.conf":
    content => template("thumbslug/etc/thumbslug/thumbslug.conf.erb"),
    require => Class["certs::config"],
    notify  => Service["thumbslug"];
  }
}
