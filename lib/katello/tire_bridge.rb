module Katello
  # We need a bridge for Tire so we can log their messages to our logger
  class TireBridge
    def initialize(logger)
      @logger = logger
    end

    # text representation of logger level
    def level
      ::Logging.levelify(::Logging::LNAMES[@logger.level])
    end

    # actual bridge to katello logger
    # we enforce debug level so messages can be easily turned on/off by setting info level
    # to tire_rest logger
    def write(message)
      @logger.debug message
    end
  end
end
