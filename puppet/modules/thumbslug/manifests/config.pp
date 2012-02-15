class thumbslug::config {
  file { "/etc/thumbslug/thumbslug.conf":
    content => template("thumbslug/etc/thumbslug/thumbslug.conf.erb"),
    notify  => Service["thumbslug"];
  }
}
