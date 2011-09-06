exec {"getRepoFile":
        command => "wget http://repos.fedorapeople.org/repos/katello/katello/fedora-katello.repo",
        creates => "/etc/yum.repos.d/fedora-katello.repo",
        cwd => "/etc/yum.repos.d",
        path => "/usr/bin"
}

file {"/etc/yum.repos.d/fedora-katello.repo":
}

package {"katello":
    ensure => installed,
    require => Exec["getRepoFile"]
}

package {"katello-cli":
    ensure => installed,
    require => Exec["getRepoFile"]
}

exec {"oauth":
        command => "/usr/share/katello/script/reset-oauth",
        notify => [Service[tomcat6], Service[pulp-server], Service[httpd]],
        require => Package[katello]
}

service {"tomcat6":
        ensure => running
}

service {"pulp-server":
        ensure => running
}

service {"httpd":
        ensure => running
}

exec {"initkatello":
        command => "service katello initdb",
        path => "/sbin",
        require => [Exec[oauth], Service[tomcat6], Service[pulp-server]]
}

service {"katello":
        ensure => running,
        enable => true,
        hasstatus => true,
        require => Exec["initkatello"]
}

service {"katello-jobs":
        ensure => running,
        enable => true,
        hasstatus => true,
        require => Exec["initkatello"]
}
