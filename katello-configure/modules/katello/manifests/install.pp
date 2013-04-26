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
    'headpin': {
      include thumbslug::install
    }
    default : {}
  }

  $os = $operatingsystem ? {
    "RedHat" => "RHEL",
    "CentOS" => "RHEL",
    default  => "Fedora"
  }

  yumrepo { "katello-nightly":
    name     => "katello-nightly",
    baseurl  => "http://fedorapeople.org/groups/katello/releases/yum/nightly/${os}/${lsbmajdistrelease}/x86_64/",
    enabled  => "1",
    gpgcheck => "0"
  }

  yumrepo { "katello-nightly-source":
    name     => "katello-nightly-source",
    baseurl  => "http://fedorapeople.org/groups/katello/releases/source/nightly/${os}/${lsbmajdistrelease}/x86_64/",
    enabled  => "0",
    gpgcheck => "0"
  }

  package {["katello", "katello-cli"]:
    require => $katello::params::deployment ? {
      'katello' => [Yumrepo["katello-nightly"],Class["pulp::install"],Class["candlepin::install"]],
      'headpin' => [Yumrepo["katello-nightly"],Class["candlepin::install"],Class["thumbslug::install"]],
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
