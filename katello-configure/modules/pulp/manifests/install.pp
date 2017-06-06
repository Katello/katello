class pulp::install {
  include mongodb::install

  $os = $operatingsystem ? {
    "RedHat" => "RHEL",
    "CentOS" => "RHEL",
    default  => "Fedora"
  }

  yumrepo { "katello-pulp":
    name     => "katello-pulp",
    baseurl  => "http://fedorapeople.org/groups/katello/releases/yum/katello-pulp/${os}/${lsbmajdistrelease}/x86_64/",
    enabled  => "1",
    gpgcheck => "0"
  }

  package{"pulp":
    ensure => installed,
    require => Yumrepo["katello-pulp"]
  }
}
