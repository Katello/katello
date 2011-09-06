class candlepin::install {
  $os_type = $operatingsystem ? {
    "Fedora" => "fedora",
    default  => "epel"
  }
  yumrepo { "candlepin":
    descr    => 'Candlepin Repo',
    baseurl  => "http://repos.fedorapeople.org/repos/candlepin/candlepin/$os_type-\$releasever/\$basearch",
    enabled  => "1",
    gpgcheck => "0"
  }

	package{"candlepin-tomcat6":
    require => Yumrepo["candlepin"],
    ensure  => installed
  }
}
