module Katello
  module Middleware
    class EventDaemon
      def initialize(app)
        @app = app
      end

      def call(env)
        if Katello::EventDaemon.runnable?
          Thread.new do
            Katello::EventDaemon.start
          end
        end
        @app.call(env)
      end
    end
  end
end
