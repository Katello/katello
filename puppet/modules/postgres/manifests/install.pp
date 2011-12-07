class postgres::install {

  package { ["postgresql-server","postgresql"]: ensure => installed }

  user { $postgres::params::user:
    shell      => '/bin/bash',
    ensure     => 'present',
    comment    => 'PostgreSQL Server',
    uid        => $postgres::params::uid,
    gid        => $postgres::params::gid,
    home       => $postgres::params::home,
    managehome => true,
    password   => '!!',
  }

  group { $postgres::params::group:
    ensure  => 'present',
    gid     => '26',
  }

  file {
    $postgres::params::home:
      owner   => $postgres::params::user,
      group   => $postgres::params::group,
      mode    => 700,
      require => User[$postgres::params::user];
  }

  File[$postgres::params::home] -> Exec["InitDB"]
  Package["postgresql-server"] -> Exec["InitDB"]
}
