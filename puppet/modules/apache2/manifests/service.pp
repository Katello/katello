class apache2::service {
  service { "httpd":
    ensure    => running,
    subscribe => Package["httpd"]
   }
}
