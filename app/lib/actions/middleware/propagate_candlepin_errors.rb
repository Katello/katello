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
      rescue HttpResource::HttpError => e
        raise(::Katello::Errors::CandlepinError.new(e.message) || e)
      end
    end
  end
end
