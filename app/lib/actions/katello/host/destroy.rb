module Actions
  module Katello
    module Host
      class Destroy < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(host, options = {})
          organization_destroy = options.fetch(:organization_destroy, false)
          unregistering = options.fetch(:unregistering, false)

          action_subject(host)

          concurrence do
            if !organization_destroy && host.subscription_facet.try(:uuid)
              plan_action(Candlepin::Consumer::Destroy, uuid: host.subscription_facet.uuid)
            end
            plan_action(Pulp::Consumer::Destroy, uuid: host.content_facet.uuid) if host.content_facet.try(:uuid)
          end

          host.subscription_facet.try(:destroy!)

          if unregistering
            unregister(host)
          elsif organization_destroy
            host.content_facet.try(:destroy!)
            destroy_host_artifacts(host)
          else
            host.content_facet.try(:destroy!)
            unless host.destroy
              fail host.errors.full_messages.join('; ')
            end
          end
        end

        def unregister(host)
          if host.content_facet
            host.content_facet.uuid = nil
            host.content_facet.save!
          end
          destroy_host_artifacts(host)
        end

        def destroy_host_artifacts(host)
          host.get_status(::Katello::ErrataStatus).destroy
          host.get_status(::Katello::SubscriptionStatus).destroy
          host.get_status(::Katello::TraceStatus).destroy
          host.installed_packages.destroy_all
        end

        def humanized_name
          _("Destroy Content Host")
        end
      end
    end
  end
end
