module Katello
  module Messaging
    class ReceivedMessage
      attr_reader :headers

      def initialize(body:, headers: {})
        @body = body
        @headers = headers
      end

      def body
        return @json_body if @json_body

        if @body.is_a?(String)
          begin
            @json_body = JSON.parse(@body).with_indifferent_access
          rescue
            @json_body = {}
          end
        end

        @json_body || @body
      end
    end
  end
end
