module Actions
  module Katello
    module Host
      class UploadPackageProfile < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(host, profile_string)
          action_subject host

          plan_self(:host_id => host.id, :hostname => host.name, :profile_string => profile_string)
          plan_action(GenerateApplicability, [host])
        end

        def humanized_name
          if input.try(:[], :hostname)
            _("Package Profile Update for %s") % input[:hostname]
          else
            _('Package Profile Update')
          end
        end

        def resource_locks
          :link
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        def run
          host = ::Host.find(input[:host_id])
          profile = JSON.parse(input[:profile_string])
          #free the huge string from the memory
          input[:profile_string] = 'TRIMMED'.freeze

          ::Katello::Pulp::Consumer.new(host.content_facet.uuid).upload_package_profile(profile) if host.content_facet.uuid
          simple_packages = profile.map { |item| ::Katello::Pulp::SimplePackage.new(item) }
          host.import_package_profile(simple_packages)
        end
      end
    end
  end
end
