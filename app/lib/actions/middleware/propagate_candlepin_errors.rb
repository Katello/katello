module Actions
  module Middleware
    class PropagateCandlepinErrors < Dynflow::Middleware
      def plan(*args)
        propagate_candlepin_errors { pass(*args) }
      end

      def run(*args)
        propagate_candlepin_errors { pass(*args) }
      end

      def finalize(*args)
        propagate_candlepin_errors { pass(*args) }
      end

      private

      def propagate_candlepin_errors
        yield
      rescue ::Katello::Errors::CandlepinError
        raise
      rescue HttpResource::HttpError => e
        display_message = e.message
        if e.response_body.present?
          parsed = JSON.parse(e.response_body) rescue {}
          display_message = parsed['displayMessage'] || display_message
        end
        raise ::Katello::Errors::CandlepinError, display_message
      end
    end
  end
end
