module Katello
  module Glue
    singleton_class.send :attr_writer, :logger
    def self.logger
      @logger ||= ::Foreman::Logging.logger('katello/glue')
    end
  end
end
