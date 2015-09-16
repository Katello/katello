module Actions
  module Katello
    module Host
      class Destroy < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(host, options = {})
          skip_candlepin = options.fetch(:skip_candlepin, false)
          destroy_aspects = options.fetch(:destroy_aspects, true)
          destroy_object = options.fetch(:destroy_object, true)

          action_subject(host)

          concurrence do
            if !skip_candlepin && host.subscription_aspect.try(:uuid)
              plan_action(Candlepin::Consumer::Destroy, uuid: host.subscription_aspect.uuid)
            end
            plan_action(Pulp::Consumer::Destroy, uuid: host.content_aspect.uuid) if host.content_aspect.try(:uuid)
          end

          if destroy_aspects
            host.subscription_aspect.try(:destroy!)
            host.content_aspect.try(:destroy!)
          else
            host.subscription_aspect.update_attributes!(:uuid => nil) if host.subscription_aspect
            host.content_aspect.update_attributes!(:uuid => nil) if host.content_aspect
          end

          host.content_host.destroy! if host.content_host

          if destroy_object
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
