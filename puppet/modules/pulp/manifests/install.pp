class pulp::install {
  $os_type = $operatingsystem ? {
    "Fedora" => "fedora-${operatingsystemrelease}",
    default  => "\$releasever"
  }

  yumrepo {
    "fedora-pulp":
      enabled  => "1",
      gpgcheck => "0",
      descr    => "Pulp Community Releases",
      baseurl  => "http://repos.fedorapeople.org/repos/pulp/pulp/${os_type}//\$basearch/";
    "testing-fedora-pulp":
      enabled  => "1",
      gpgcheck => "0",
      descr    => "Pulp Community Releases",
      baseurl  => "http://repos.fedorapeople.org/repos/pulp/pulp/testing/${os_type}/\$basearch/";
  }

  package{"pulp":
    ensure => installed,
    require => Yumrepo["fedora-pulp","testing-fedora-pulp"]
  }
}
