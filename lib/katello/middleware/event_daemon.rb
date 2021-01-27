module Katello
  module Middleware
    class EventDaemon
      def initialize(app)
        @app = app
      end

      def call(env)
        Katello::EventDaemon::Runner.start
        @app.call(env)
      end
    end
  end
end
