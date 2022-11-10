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
        error_class = if e.response.request.url.include?('/candlepin')
                        ::Katello::Errors::CandlepinError
                      else
                        ::Katello::Errors::UpstreamCandlepinError
                      end
        raise(error_class.from_exception(e) || e)
      end
    end
  end
end
