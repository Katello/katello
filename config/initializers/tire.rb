Tire::Configuration.url(Katello.config.elastic_url)

Tire.configure { logger 'log/elasticsearch.log' } if Katello.config.tire_log
