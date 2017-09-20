module Actions
  module Middleware
    class KeepSessionId < Dynflow::Middleware
      def plan(*args)
        pass(*args).tap do
          action.input[:session_id] = ::Logging.mdc['request']
        end
      end

      def run(*args)
        with_session_id { pass(*args) }
      end

      def finalize
        with_session_id { pass }
      end

      private

      def with_session_id(&_block)
        original_session_id = ::Logging.mdc['request']
        ::Logging.mdc['request'] = action.input[:session_id]
        yield
      ensure
        ::Logging.mdc['request'] = original_session_id
      end
    end
  end
end
