module Katello
  module Middleware
    class LogRequestUUID
      def initialize(app)
        @app = app
      end

      def call(env)
        ::Logging.mdc['uuid'] = env['action_dispatch.request_id']
        @app.call(env)
      ensure
        ::Logging.mdc.delete 'uuid'
      end
    end
  end
end
