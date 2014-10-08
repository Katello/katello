
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
    class ConnectionError < StandardError
    end

    class CandlepinListeningService
      RECONNECT_ATTEMPTS = 30
      TIMEOUT =  Qpid::Messaging::Duration::SECOND
      NO_MESSAGE_AVAILABLE_ERROR_TYPE = 'NoMessageAvailable'

      class << self
        attr_reader :instance

        def initialize(logger, url, address)
          @instance ||= self.new(logger, url, address)
        end

        def close
          @instance.close if @instance
          @instance = nil
        end
      end

      def initialize(logger, url, address)
        @url = url
        @address = address
        @connection = create_connection
        @logger = logger
      end

      def create_connection
        Qpid::Messaging::Connection.new(:url => @url, :options => {:transport => 'ssl'})
      end

      def close
        @thread.kill if @thread
        @connection.close
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

      def start(suspended_action)
        unless @connection.open?
          @connection.open
          @session = @connection.create_session
          @receiver = @session.create_receiver(@address)
        end
        if @connection.open?
          suspended_action.notify_connected
        else
          suspended_action.notify_not_connected("Not Connected")
        end
      rescue TransportFailure => e
        suspended_action.notify_not_connected(e.message)
      end

      def fetch_message(suspended_action)
        result = nil
        begin
          result = retrieve
        rescue Actions::Candlepin::ConnectionError => e
          suspended_action.notify_not_connected(e.message)
        end
        result
      end

      def poll_for_messages(suspended_action)
        @thread.kill if @thread
        @thread = Thread.new do
          loop do
            begin
              message = fetch_message(suspended_action)
              if message
                @session.acknowledge(:message => message)
                suspended_action.notify_message_recieved(message.message_id, message.subject, message.content)
              end
              sleep 1
            rescue => e
              suspended_action.notify_fatal(e)
              raise e
            end
          end
        end
      end
    end
  end
end
