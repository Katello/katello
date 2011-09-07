class postgres::install {

  package { ["postgresql-server","postgresql"]: ensure => installed }

}
