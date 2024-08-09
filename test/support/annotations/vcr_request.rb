module Katello
  module Annotations
    class VcrRequest
      attr_reader :method, :path, :request_body, :response_body, :response_code

      def initialize(hash)
        @response_body = decode_body(hash.fetch('response').fetch('body'))
        @request_body = decode_body(hash.fetch('request').fetch('body'))
        @method = hash.fetch('request').fetch('method')
        @path = URI(hash.fetch('request').fetch('uri')).path
      end

      def generate_template
        {
          'method' => method,
          'path' => path,
          'title' => nil,
          'description' => nil,
        }
      end

      def decode_body(body)
        if body && body['base64_string']
          Base64.decode64(body['base64_string'])
        elsif body
          body
        end
      end

      def self.load_requests(cassette_name)
        cassette = YAML.load_file(cassette_name)
        cassette['http_interactions'].map { |request| Annotations::VcrRequest.new(request) }
      end
    end
  end
end
