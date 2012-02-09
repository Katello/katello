class elasticsearch::config {
  file {
    "/etc/elasticsearch/elasticsearch.yml":
      content => template("elasticsearch/etc/elasticsearch/elasticsearch.yml.erb"),
  }  

  file { "/var/run/elasticsearch":
     ensure => directory,
     mode => 644,
     owner => "elasticsearch",
     group => "elasticsearch";
  }
  
  # Set elasticsearch's heap sizes
  exec { "/bin/sed -i '1i ES_MIN_MEM=1512m' /usr/share/java/elasticsearch/bin/elasticsearch.in.sh":
       unless => "/bin/grep -qFx 'ES_MIN_MEM=1512m' /usr/share/java/elasticsearch/bin/elasticsearch.in.sh"
  }
  exec { "/bin/sed -i '1i ES_MAX_MEM=1512m' /usr/share/java/elasticsearch/bin/elasticsearch.in.sh":
       unless => "/bin/grep -qFx 'ES_MAX_MEM=1512m' /usr/share/java/elasticsearch/bin/elasticsearch.in.sh"
  }
}
