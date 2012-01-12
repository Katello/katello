Tire::Configuration.url(AppConfig.elastic_url)

Tire.configure { logger 'log/elasticsearch.log' } if AppConfig.tire_log
