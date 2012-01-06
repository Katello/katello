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
}
