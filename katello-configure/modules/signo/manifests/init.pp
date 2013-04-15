class signo {
  include apache2
  include signo::install
  include signo::config
  include signo::service
}