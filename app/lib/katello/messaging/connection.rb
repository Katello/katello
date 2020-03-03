module Katello
  module Messaging
    class Connection
      def self.create(connection_class:, settings:)
        connection = connection_class.new(settings: settings)

        at_exit do
          connection.close
        end

        connection
      end
    end
  end
end
