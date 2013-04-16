class candlepin::install {
  $os = $operatingsystem ? {
    "RedHat" => "RHEL",
    "CentOS" => "RHEL",
    default  => "Fedora"
  }

  yumrepo { "katello-candlepin":
    name     => "katello-candlepin",
    baseurl  => "http://fedorapeople.org/groups/katello/releases/yum/katello-candlepin/${os}/${lsbmajdistrelease}/x86_64/",
    enabled  => "1",
    gpgcheck => "0"
  }

	package {"candlepin-tomcat6":
    require => Yumrepo["katello-candlepin"],
    ensure  => installed
  }
}
