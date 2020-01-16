require 'stomp'

module Katello
  module Messaging
    class Connection
      def self.for_client(client_id, logger = Rails.logger)
        @pool ||= {}

        @pool[client_id] ||= begin
          config = {
            client: {
              hosts: [
                {
                  connect_timeout: 3,
                  host: 'localhost',
                  port: '61613',
                  ssl: false,
                  logger: logger,
                  start_timeout: 2,
                  use_exponential_back_off: true
                }
              ],
              connect_headers: {
                'accept-version': '1.2',
                'host': 'localhost',
                'heart-beat': '30000,0',
                'client-id': client_id
              }
            }
          }
          connection = new(client_id, config)
          at_exit do
            connection.close
          end

          connection
        end
      end

      def self.close_for_client(client_id)
        @pool[client_id] = nil
        Rails.logger.debug("Messaging connection closed client=#{client_id}")
      end

      def self.close_all
        return unless @pool
        @pool.values.each do |connection|
          connection&.close
        end
      end

      def initialize(client_id, config)
        @client = ::Stomp::Client.new(config[:client])
        @client_id = client_id
        @subscribed_queues = []
        @encoding = :json
      end

      def subscribe(queue_name, subscription_name = nil)
        options = {}
        options['ack'] = 'client-individual'
        options['durable-subscription-name'] = subscription_name if subscription_name

        @subscribed_queues << queue_name
        @client.subscribe(queue_name, options) do |message|
          received_message = Katello::Messaging::ReceivedMessage.new(message.body, message.headers, @client)
          yield(received_message)
          @client.ack(message)
        end
        Rails.logger.info("Subscribed to #{queue_name}.#{subscription_name}")
      end

      def publish(queue_name, message, headers)
        if message && @encoding == :json
          message = message.to_json
        end
        @client.publish(queue_name, message, headers)
      end

      def ack(message)
        @client.ack(message)
      end

      def running?
        @client.running && @client.open?
      end

      def unsubscribe_all
        @subscribed_queues.each do |queue|
          @client.unsubscribe(queue)
          Rails.logger.info("Unsubscribed from #{queue}")
        end
      end

      def open?
        @client.open?
      end

      def close
        if @client.open?
          @client.close
          self.class.close_for_client(@client_id)
        end
      end
    end
  end
end
