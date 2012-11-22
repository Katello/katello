class elasticsearch::config {
  file { "/etc/elasticsearch/elasticsearch.yml":
    content => template("elasticsearch/etc/elasticsearch/elasticsearch.yml.erb"),
    notify  => Service["elasticsearch"];
  }  

  file { "/var/run/elasticsearch":
     ensure => directory,
     mode => 644,
     owner => "elasticsearch",
     group => "elasticsearch",
  }

  file { "/etc/sysconfig/elasticsearch":
    content => template("elasticsearch/etc/sysconfig/elasticsearch.erb"),
    notify  => Service["elasticsearch"];
  }

  if $elasticsearch::params::reset_data == 'YES' {
    exec {"reset_elasticsearch_data":
      command => "rm -rf /var/lib/elasticsearch/*",
      path    => "/sbin:/bin:/usr/bin",
      notify  => Service["elasticsearch"],
    }
  }
}
