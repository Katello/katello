module Actions
  module Katello
    module Host
      class UploadProfiles < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(host, profile_string)
          action_subject host

          sequence do
            plan_self(:host_id => host.id, :hostname => host.name, :profile_string => profile_string)
            plan_action(GenerateApplicability, [host])
          end
        end

        def humanized_name
          if input.try(:[], :hostname)
            _("Combined Profile Update for %s") % input[:hostname]
          else
            _('Combined Profile Update')
          end
        end

        def resource_locks
          :link
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        def run
          profiles = JSON.parse(input[:profile_string])
          #free the huge string from the memory
          input[:profile_string] = 'TRIMMED'.freeze
          host = ::Host.find_by(:id => input[:host_id])
          if host.nil?
            Rails.logger.warn("Host with ID %s not found, continuing" % input[:host_id])
          elsif host.content_facet.nil? || host.content_facet.uuid.nil?
            Rails.logger.warn("Host with ID %s has no content facet, continuing" % input[:host_id])
          else
            package_profile = nil
            modulemd_inventory = nil
            enabled_repos = nil
            profiles.each do |profile|
              payload = profile["profile"]
              case profile["content_type"]
              when "rpm"
                package_profile = payload
              when "enabled_repos"
                enabled_repos = payload
              else
                modulemd_inventory = payload
              end
            end
            UploadPackageProfile.upload(input, package_profile)
            host.import_enabled_repositories(enabled_repos)
            host.import_module_streams(modulemd_inventory)
          end
        end
      end
    end
  end
end
