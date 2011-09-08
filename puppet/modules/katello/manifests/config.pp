class katello::config {
  exec {"oauth":
    command => "/usr/share/katello/script/reset-oauth",
    notify  => [Class["candlepin::service"], Class["pulp::service"]],
    creates => "/var/lib/katello/initdb_done",
    require => Class["katello::install"]
  }

  exec {"initkatello":
    command => "service katello initdb",
    path    => "/sbin",
    creates => "/var/lib/katello/initdb_done",
    require => Exec[oauth],
  }
}
