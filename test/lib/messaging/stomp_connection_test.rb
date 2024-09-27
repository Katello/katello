require 'katello_test_helper'
require 'stomp'
require_relative '../../../app/lib/katello/messaging/stomp_connection'

module Katello
  module Messaging
    class StompConnectionTest < ActiveSupport::TestCase
      def setup
        @stomp_client = mock('stomp_client')
        Stomp::Client.stubs(:new).returns @stomp_client

        @settings = {
          queue_name: 'my_queue',
          subscription_name: 'my_subscription',
          client_id: 'my_client_id',
        }
        @connection = Katello::Messaging::StompConnection.new(settings: @settings)
      end

      def test_subscribe
        expected_options = {
          'ack' => 'client-individual',
          'durable-subscription-name' => @settings[:subscription_name],
        }
        @stomp_client.expects(:subscribe).with(@settings[:queue_name], expected_options)

        @connection.subscribe
      end

      def test_running?
        refute @connection.running?
      end

      def test_open?
        refute @connection.open?
      end

      def test_close
        refute @connection.close
      end
    end
  end
end
