require 'katello_test_helper'

module Katello
  module Messaging
    class ConnectionTest < ActiveSupport::TestCase
      class DummyConnection
        def initialize(settings:)
          @settings = settings
        end

        def close
          @settings[:close_signal]
        end
      end

      def test_create
        connection = Katello::Messaging::Connection.create(
          connection_class: DummyConnection,
          settings: { close_signal: :closed }
        )

        assert_equal :closed, connection.close
      end
    end
  end
end
