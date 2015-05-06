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
      rescue RestClient::ExceptionWithResponse => e
        raise(::Katello::Errors::CandlepinError.from_exception(e) || e)
      end
    end
  end
end
