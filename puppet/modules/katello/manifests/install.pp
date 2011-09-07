class katello::install {
  yumrepo { "fedora-katello":
    descr    => 'integrates together a series of open source systems management tools',
    baseurl  => "http://repos.fedorapeople.org/repos/katello/katello/\$releasever/\$basearch/",
    enabled  => "1",
    gpgcheck => "0"
  }
  yumrepo { "fedora-katello-source":
    descr    => 'integrates together a series of open source systems management tools',
    baseurl  => "http://repos.fedorapeople.org/repos/katello/katello/\$releasever/\$basearch/SRPMS",
    enabled  => "0",
    gpgcheck => "0"
  }

	package{["katello", "katello-cli"]:
    require => [Yumrepo["fedora-katello"],Class["pulp::install"],Class["candlepin::install"]],
    ensure  => installed
  }
}
