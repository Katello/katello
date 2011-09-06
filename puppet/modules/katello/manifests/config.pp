class katello::config {
  exec {"oauth":
    command => "/usr/share/katello/script/reset-oauth",
    notify  => [Class["candlepin::service"], Class["pulp::service"]],
    require => Class["katello::install"]
  }

  exec {"initkatello":
    command => "service katello initdb",
    path    => "/sbin",
    require => Exec[oauth],
  }
}
