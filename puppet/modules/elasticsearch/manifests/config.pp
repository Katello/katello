class elasticsearch::config {
  file { "/etc/elasticsearch/elasticsearch.yml":
    content => template("elasticsearch/etc/elasticsearch/elasticsearch.yml.erb"),
  }  

  file { "/var/run/elasticsearch":
     ensure => directory,
     mode => 644,
     owner => "elasticsearch",
     group => "elasticsearch",
  }
  
  # Set elasticsearch's heap sizes
  exec { "/bin/sed -i '/#ES_MIN_MEM=/c ES_MIN_MEM=256m' /etc/sysconfig/elasticsearch":
       unless => "/bin/grep -qFx 'ES_MIN_MEM=256m' /etc/sysconfig/elasticsearch"
  }
  exec { "/bin/sed -i '/#ES_MAX_MEM=/c ES_MAX_MEM=256m' /etc/sysconfig/elasticsearch":
       unless => "/bin/grep -qFx 'ES_MAX_MEM=256m' /etc/sysconfig/elasticsearch"
  }
}
