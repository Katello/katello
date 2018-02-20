module Actions
  module Katello
    module Host
      class Destroy < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(host, options = {})
          action_subject(host)
          # normalize options before passing through to run phase
          organization_destroy = options.fetch(:organization_destroy, false)
          unregistering = options.fetch(:unregistering, false)
          plan_self(:hostname => host.name, :host_id => host.id, :unregistering => unregistering,
                    :organization_destroy => organization_destroy)
        end

        def run
          host = ::Host.find(input[:host_id])
          ::Katello::RegistrationManager.unregister_host(host, :unregistering => input[:unregistering],
                                                         :organization_destroy => input[:organization_destroy])
        rescue ActiveRecord::RecordNotFound
          Rails.logger.warn("Attempted to delete host %s in action, but host is already gone. Continuing." % input[:host_id])
        end

        def humanized_name
          if input.try(:[], :hostname)
            _("Destroy Content Host %s") % input[:hostname]
          else
            _("Destroy Content Host")
          end
        end
      end
    end
  end
end
