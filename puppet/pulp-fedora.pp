exec {"getRepoFile":
        command => "wget http://repos.fedorapeople.org/repos/pulp/pulp/fedora-pulp.repo",
        creates => "/etc/yum.repos.d/fedora-pulp.repo",
        cwd => "/etc/yum.repos.d",
        path => "/usr/bin"
}

file {"/etc/yum.repos.d/fedora-pulp.repo":
}

augeas {"fedora-pulp.repo":
        context => "/files/etc/yum.repos.d/fedora-pulp.repo/testing-fedora-pulp",
        changes => ["set enabled 1"],
        require => Exec["getRepoFile"]
}

package {"pulp":
    ensure => installed,
    require => Augeas["fedora-pulp.repo"]
}

file {"/etc/pki/pulp/ca.crt":
    ensure => link,
    target => "/etc/candlepin/certs/candlepin-ca.crt",
    require => Package[pulp]}

file {"/etc/pki/pulp/ca.key":
    ensure => link,
    target => "/etc/candlepin/certs/candlepin-ca.key",
    require => Package[pulp]}



exec {"initpulp":
        command => "service pulp-server init",
        creates => "/var/lib/pulp/init.flag",
        path => "/sbin",
        subscribe => Package[pulp]
}

exec {"setenforce":
        command => "setenforce 0",
        path => "/usr/sbin",
}

service {"pulp-server":
        ensure => running,
        enable => true,
        hasstatus => true,
        require => Exec["initpulp"]
}

service {"httpd":
        ensure => running,
        enable => true,
        hasstatus => true,
        require => Exec["initpulp"]
}
