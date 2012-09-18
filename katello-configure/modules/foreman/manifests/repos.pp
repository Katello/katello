class foreman::repos {
  $os_type = $operatingsystem ? {
    "Fedora" => "Fedora",
    default  => "RHEL"
  }

  yumrepo { "katello-foreman":
    descr    => 'configuration and provisioning management tool',
    baseurl  => "http://fedorapeople.org/groups/katello/releases/yum/katello-foreman/$os_type/\$releasever/\$basearch/",
    enabled  => "1",
    gpgcheck => "0";
  }
}
