class pulp::install {
  yumrepo {
    "fedora-pulp":
      enabled  => "1",
      gpgcheck => "0",
      descr    => "Pulp Community Releases",
      baseurl  => "http://repos.fedorapeople.org/repos/pulp/pulp/\$releasever/\$basearch/";
    "testing-fedora-pulp":
      enabled  => "1",
      gpgcheck => "0",
      descr    => "Pulp Community Releases",
      baseurl  => "http://repos.fedorapeople.org/repos/pulp/pulp/testing/\$releasever/\$basearch/";
  }

  package{"pulp":
    ensure => installed,
    require => Yumrepo["fedora-pulp","testing-fedora-pulp"]
  }
}
