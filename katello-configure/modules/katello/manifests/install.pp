class katello::install {
  include katello

  include candlepin::install
  include postgres::install
  include apache2::install

  # Headpin does not care about pulp
  case $katello::params::deployment {
    'katello': {
      include pulp::install
      include qpid::install
    }
    default : {}
  }

  $os_type = $operatingsystem ? {
    "Fedora" => "fedora-${operatingsystemrelease}",
    default  => "\$releasever"
  }

  yumrepo { "fedora-katello":
    descr    => 'integrates together a series of open source systems management tools',
    baseurl  => "http://repos.fedorapeople.org/repos/katello/katello/$os_type/\$basearch/",
    enabled  => "1",
    gpgcheck => "0"
  }

  yumrepo { "fedora-katello-source":
    descr    => 'integrates together a series of open source systems management tools',
    baseurl  => "http://repos.fedorapeople.org/repos/katello/katello/$os_type/\$basearch/SRPMS",
    enabled  => "0",
    gpgcheck => "0"
  }

	package{["katello", "katello-cli"]:
    require => $katello::params::deployment ? {
                'katello' => [Yumrepo["fedora-katello"],Class["pulp::install"],Class["candlepin::install"]],
                'headpin' => [Yumrepo["fedora-katello"],Class["candlepin::install"],Class["thumbslug::install"]],
                default => []
    },
    before  => $katello::params::deployment ? {
                'katello' =>  [Class["candlepin::config"], Class["pulp::config"] ], #avoid some funny post rpm scripts
                'headpin' =>  [Class["candlepin::config"], Class["thumbslug::config"]], #avoid some funny post rpm scripts
                default => []
    },
    ensure  => installed
  }

  Class["katello::install"] -> File["${katello::params::log_base}"]
  Class["katello::install"] -> File["${katello::params::config_dir}/thin.yml"]
  Class["katello::install"] -> File["${katello::params::config_dir}/katello.yml"]
  Class["katello::install"] -> File["/etc/httpd/conf.d/katello.conf"]
}
