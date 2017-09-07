module Actions
  module Katello
    module Host
      class UpdateReleaseVersion < Actions::EntryAction
        def plan(host, release_version)
          plan_self(:hostname => host.name)
          if host.content_facet && host.subscription_facet
            if release_version.present? && !host.content_facet.available_releases.include?(release_version)
              fail _("Host %{name} cannot be assigned release version %{release_version}.") % { :name => host.name, :release_version => release_version }
            else
              host.subscription_facet.release_version = release_version
            end
            plan_action(Actions::Katello::Host::Update, host)
          else
            fail _("Host %s has not been registered with subscription-manager.") % host.name
          end
        end

        def humanized_name
          if input.try(:[], :hostname).nil?
            _("Update release version for host")
          else
            _("Update release version for host %s") % input[:hostname]
          end
        end
      end
    end
  end
end
