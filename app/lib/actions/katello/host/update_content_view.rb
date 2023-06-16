module Actions
  module Katello
    module Host
      class UpdateContentView < Actions::EntryAction
        def plan(host, content_view_id, lifecycle_environment_id)
          if host.content_facet
            host.content_facet.assign_single_environment(
              content_view_id: content_view_id,
              lifecycle_environment_id: lifecycle_environment_id
            )
            host.update_candlepin_associations
            plan_self(:hostname => host.name)
          else
            fail _("Host %s has not been registered with subscription-manager.") % host.name
          end
        end

        def humanized_name
          if input.try(:[], :hostname).nil?
            _("Update for host")
          else
            _("Update for host %s") % input[:hostname]
          end
        end
      end
    end
  end
end
