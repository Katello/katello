module Actions
  module Middleware
    class BackendServicesCheck < Dynflow::Middleware
      def plan(*args)
        if Setting[:check_services_before_actions]
          #To prevent the ping from happening multiple times, keep track on the initial entry action
          #If capsule_id is passed as in args from an action, Katello::Ping checks the pulp server on the capsule
          parent = source_action
          parent.input[:services_checked] ||= []
          to_check = services - parent.input[:services_checked]

          if to_check.any?
            result = User.as_anonymous_admin { ::Katello::Ping.ping(services: to_check, capsule_id: capsule_id(args))[:services] }

            to_check.each do |service|
              if result[service][:status] != ::Katello::Ping::OK_RETURN_CODE
                fail _("There was an issue with the backend service %s: ") % service + result[service][:message]
              end
            end
            parent.input[:services_checked].concat(to_check)
          end
        end
        pass(*args)
      end

      protected

      def capsule_id(args)
        capsule_id = nil
        args.each do |arg|
          case arg
          when SmartProxy
            capsule_id = arg.id
          when Hash
            capsule_id = arg[:capsule_id] || arg[:smart_proxy_id]
          end
          break if capsule_id
        end
        capsule_id
      end

      def source_action
        parent = self.action
        until parent.triggering_action.nil?
          parent = parent.triggering_action
        end
        parent
      end

      def services
        fail _("No services defined, is this class extended?")
      end
    end
  end
end
