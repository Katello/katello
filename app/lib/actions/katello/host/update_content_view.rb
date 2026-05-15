module Actions
  module Katello
    module Host
      class UpdateContentView < Actions::EntryAction
        def plan(host, content_view_id, lifecycle_environment_id)
          if host.content_facet
            cve = ::Katello::ContentViewEnvironment.find_by_cv_and_lce!(content_view_id, lifecycle_environment_id)
            host.content_facet.content_view_environments = [cve]
            host.update_candlepin_associations
            plan_self(:hostname => host.name)
          else
            fail _("Host %s has not been registered with subscription-manager.") % host.name
          end
        end

        def humanized_name
          if input.try(:[], :hostname).nil?
            _("Update content view environments for host")
          else
            _("Update content view environments for host %s") % input[:hostname]
          end
        end
      end
    end
  end
end
