Tire::Configuration.url(Katello.config.elastic_url)

bridge = Katello::LoggingImpl::TireBridge.new(Logging.logger['tire_rest'])
Tire.configure { logger bridge, :level => bridge.level }