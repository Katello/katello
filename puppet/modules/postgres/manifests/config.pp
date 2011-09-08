class postgres::config {

  user { $postgres::params::user:
    shell      => '/bin/bash',
    ensure     => 'present',
    comment    => 'PostgreSQL Server',
    uid        => $postgres::params::uid,
    gid        => $postgres::params::gid,
    home       => $postgres::params::home,
    managehome => true,
    password   => '!!',
    require    => Class["postgres::install"],
  }

  group { $postgres::params::group:
    ensure  => 'present',
    gid     => '26',
    require => Class["postgres::install"],
  }

  file {
    $postgres::params::home:
      owner   => $postgres::params::user,
      group   => $postgres::params::group,
      mode    => 700,
      require => User[$postgres::params::user];

    "${postgres::params::home}/data/postgresql.conf":
      content => template("postgres/postgresql.conf.erb"),
      owner   => $postgres::params::user,
      group   => $postgres::params::group,
      notify  => Service["postgresql"],
      require => Exec["InitDB"];

    "${postgres::params::home}/data/pg_hba.conf":
      content => template("postgres/pg_hba.conf.erb"),
      owner   => "root",
      group   => "root",
      notify  => Service["postgresql"],
      require => Exec["InitDB"];
  }
  exec { "InitDB":
    command => $postgres::params::password ? {
      ""      => "/usr/bin/initdb ${postgres::params::home}//data -E UTF8",
      #horribale hack
      default => "echo \"${postgres::params::password}\" > /tmp/ps && /usr/bin/initdb ${postgres::params::home}/data --auth='password' --pwfile=/tmp/ps -E UTF8 ; rm -rf /tmp/ps"
    },
    require => File[$postgres::params::home],
    user    => $postgres::params::user,
    creates  => "${postgres::params::home}/data/PG_VERSION",
  }

}
