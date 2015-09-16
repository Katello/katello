module Actions
  module Katello
    module Host
      class UploadPackageProfile < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(host, profile)
          action_subject host

          ::Katello::Pulp::Consumer.new(host.content_aspect.uuid).upload_package_profile(profile) if host.content_aspect.uuid
          simple_packages = profile.map { |item| ::Katello::Glue::Pulp::SimplePackage.new(item) }
          host.import_package_profile(simple_packages)

          plan_self(:hostname => host.name)
          plan_action(GenerateApplicability, [host])
        end

        def humanized_name
          _("Package Profile Update for %s") % input[:hostname]
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
