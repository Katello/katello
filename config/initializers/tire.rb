Tire::Configuration.url(Katello.config.elastic_url)

bridge = Katello::Logging::TireBridge.new(Logging.logger['tire_rest'])
Tire.configure { logger bridge, :level => bridge.level } if Katello.config.tire_log