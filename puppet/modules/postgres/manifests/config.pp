class postgres::config {

  file {
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
    user    => $postgres::params::user,
    creates  => "${postgres::params::home}/data/PG_VERSION",
  }

}
