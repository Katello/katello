module Actions
  module Katello
    module Host
      class UpdateContentView < Actions::EntryAction
        def plan(host, content_view_id, lifecycle_environment_id)
          if host.content_facet
            host.content_facet.content_view = ::Katello::ContentView.find(content_view_id)
            host.content_facet.lifecycle_environment = ::Katello::KTEnvironment.find(lifecycle_environment_id)
            plan_action(Actions::Katello::Host::Update, host)
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
