class apache2::service {
  service { "httpd":
    ensure    => running, enable => true, hasstatus => true, hasrestart => true,
    subscribe => Package["httpd"]
   }
}
