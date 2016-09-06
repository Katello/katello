module Actions
  module Katello
    module Host
      class Destroy < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(host, options = {})
          skip_candlepin = options.fetch(:skip_candlepin, false)
          unregistering = options.fetch(:unregistering, false)

          action_subject(host)

          concurrence do
            if !skip_candlepin && host.subscription_facet.try(:uuid)
              plan_action(Candlepin::Consumer::Destroy, uuid: host.subscription_facet.uuid)
            end
            plan_action(Pulp::Consumer::Destroy, uuid: host.content_facet.uuid) if host.content_facet.try(:uuid)
          end

          host.subscription_facet.try(:destroy!)

          if unregistering
            if host.content_facet
              host.content_facet.uuid = nil
              host.content_facet.save!
            end

            host.get_status(::Katello::ErrataStatus).destroy
            host.get_status(::Katello::SubscriptionStatus).destroy
            host.installed_packages.destroy_all
          else
            host.content_facet.try(:destroy!)
            unless host.destroy
              fail host.errors.full_messages.join('; ')
            end
          end
        end

        def humanized_name
          _("Destroy Content Host")
        end
      end
    end
  end
end
