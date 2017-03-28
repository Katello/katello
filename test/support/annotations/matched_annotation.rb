module Katello
  module Annotations
    class MatchedAnnotation
      attr_accessor :requests
      attr_reader :annotation, :method, :path, :description, :title,
                    :ignore_duplicates, :starts_with, :ignored_count, :request_body

      def initialize(hash)
        @requests = []
        @method = hash['method']
        @path = hash['path']
        @description = hash['description']
        @title = hash['title']
        @request_body = hash['request_body']
        @ignore_duplicates = hash.fetch('ignore_duplicates', false)
        @starts_with = hash['starts_with']
        @hash = hash
      end

      def backend_service
        if self.path.starts_with?('/pulp')
          'pulp'
        elsif self.path.starts_with?('/candlepin')
          'candlepin'
        else
          'unknown'
        end
      end

      def matched?
        requests.any?
      end

      def add_matches(vcr_requests)
        vcr_requests.each do |vcr_request|
          next if self.requests.any? && !self.ignore_duplicates
          next unless request_body_includes(vcr_request)
          next unless vcr_request.method.downcase == self.method.downcase
          matched = false
          if self.path
            matched = vcr_request.path == self.path
          elsif vcr_request.path.starts_with?(self.starts_with)
            matched = true
            @path = vcr_request.path
          end
          self.requests << vcr_request if matched
        end
      end

      def request_body_includes(vcr_request)
        return true unless request_body
        vcr_request.request_body.include?(request_body)
      end

      def details
        "#{method} #{path}"
      end

      def documented?
        self.title.blank?
      end
    end
  end
end
