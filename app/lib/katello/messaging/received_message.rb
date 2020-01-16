module Katello
  module Messaging
    class ReceivedMessage
      attr_reader :headers, :body

      def initialize(body, headers, client)
        @body = body
        @headers = headers
        @client = client
        @encoding = :json
      end

      def ack
        # TODO
        @client.ack
      end
    end
  end
end
