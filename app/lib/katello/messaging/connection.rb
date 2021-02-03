module Katello
  module Messaging
    class Connection
      def self.create(connection_class:, settings:)
        connection_class.new(settings: settings)
      end
    end
  end
end
