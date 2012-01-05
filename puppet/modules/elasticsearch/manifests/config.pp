class elasticsearch::config {
  file {
    "/etc/elasticsearch/elasticsearch.yml":
      content => template("elasticsearch/etc/elasticsearch/elasticsearch.yml.erb"),
  }  
}
