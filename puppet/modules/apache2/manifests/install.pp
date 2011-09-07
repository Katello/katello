class apache2::install {
  package { "httpd": ensure => installed}
}
