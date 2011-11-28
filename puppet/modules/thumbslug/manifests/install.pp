class thumbslug::install {
  $os_type = $operatingsystem ? {
    "Fedora" => "fedora",
    default  => "epel"
  }
  yumrepo { "thumbslug":
    descr    => 'Thumbslug Repo',
    baseurl  => "http://repos.fedorapeople.org/repos/candlepin/thumbslug/$os_type-\$releasever/\$basearch",
    enabled  => "1",
    gpgcheck => "0"
  }

	package{"thumbslug":
    require => Yumrepo["thumbslug"],
    ensure  => installed
  }
}
