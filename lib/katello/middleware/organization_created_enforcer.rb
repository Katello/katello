module Katello
  module Middleware
    class OrganizationCreatedEnforcer
      def initialize(app)
        @app = app
        @all_organizations_created = false
      end

      def call(env)
        unless @all_organizations_created
          begin
            Katello::OrganizationCreator.create_all_organizations!
            @all_organizations_created = true
          rescue Katello::Errors::CandlepinNotRunning, Katello::Errors::PingError
            ::Katello::UINotifications::SystemError.deliver!({})
          end
        end
        @app.call(env)
      end
    end
  end
end
