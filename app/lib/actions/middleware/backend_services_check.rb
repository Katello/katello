module Actions
  module Middleware
    class BackendServicesCheck < Dynflow::Middleware
      def plan(*args)
        if Setting[:check_services_before_actions]
          #To prevent the ping from happening multiple times, keep track on the initial entry action
          parent = source_action
          parent.input[:services_checked] ||= []
          to_check = services - parent.input[:services_checked]

          if to_check.any?
            result = User.as_anonymous_admin { ::Katello::Ping.ping(to_check)[:services] }

            to_check.each do |service|
              if result[service][:status] != ::Katello::Ping::OK_RETURN_CODE
                fail _("There was an issue with the backend service %s: ")  % service + result[service][:message]
              end
            end
            parent.input[:services_checked].concat(to_check)
          end
        end
        pass(*args)
      end

      protected

      def source_action
        parent = self.action
        until parent.trigger.nil?
          parent = parent.trigger
        end
        parent
      end

      def services
        fail _("No services defined, is this class extended?")
      end
    end
  end
end
