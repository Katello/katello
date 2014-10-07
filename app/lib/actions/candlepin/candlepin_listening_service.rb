
#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
module Actions
  module Candlepin
    class MessageStore
      def initialize
        @messages = {}
      end

      def add(id, message)
        @messages[id] = message
      end

      def delete(id)
        @messages.delete(id) if @messages.key?(id)
      end

      def message(id)
        @messages[id]
      end
    end

    class ConnectionError < StandardError
    end

    class CandlepinListeningService
      RECONNECT_ATTEMPTS = 30
      TIMEOUT =  Qpid::Messaging::Duration::SECOND
      NO_MESSAGE_AVAILABLE_ERROR_TYPE = 'NoMessageAvailable'

      attr_reader :messages, :errors

      class << self
        attr_reader :instance

        def initialize(logger, url, address)
          @instance ||= self.new(logger, url, address)
        end

        def close
          @instance.close
          @instance = nil
        end
      end

      def initialize(logger, url, address)
        @url = url
        @address = address
        @connection = create_connection
        @messages = MessageStore.new
        @errors = {}
        @counter = 0
        @logger = logger
      end

      def create_connection
        Qpid::Messaging::Connection.new({:url => @url, :options => {:transport => 'ssl'}})
      end

      def close
        @connection.close
      ensure
        super
      end

      def retrieve
        return @receiver.fetch(TIMEOUT)
      rescue => e
        if e.class.name.include? "TransportFailure"
          raise ::Actions::Candlepin::ConnectionError, "failed to connect to #{@url}"
        else
          raise e unless e.class.name.include? NO_MESSAGE_AVAILABLE_ERROR_TYPE
        end
      end

      def acknowledge_message(message_id)
        @session.acknowledge(@messages.message(message_id))
        @messages.delete(message_id)
      end

      def start(suspended_action)
        unless @connection.open?
          @connection.open
          @session = @connection.create_session
          @receiver = @session.create_receiver(@address)
          @messages = Actions::Candlepin::MessageStore.new
        end
        if @connection.open?
          suspended_action.notify_connected
        else
          suspended_action.notify_not_connected("Not Connected")
        end
      rescue TransportFailure => e
        suspended_action.notify_not_connected(e.message)
      end

      def close
        @thread.kill if @thread
      end

      def fetch_message(suspended_action)
        result = nil
        begin
          result = retrieve
        rescue Actions::Candlepin::ConnectionError => e
          suspended_action.notify_not_connected(e.message)
        rescue => e
          notify_fatal(e)
          raise e
        end
        result
      end

      def poll_for_messages(suspended_action)
        @thread.kill if @thread
        @thread = Thread.new do
          loop do
            @counter += 1
            message = fetch_message(suspended_action)
            if message
              messages.add(@counter, message)
              suspended_action.notify_message_recieved(@counter)
            end
            sleep 3
          end
        end
      end

      def notify_fatal(error, suspended_action)
        @errors[@counter] = error
        suspended_action.notify_fatal(@counter)
      end
    end
  end
end
