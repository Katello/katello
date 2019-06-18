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

        def import_module_streams(payload, host)
          enabled_payload = payload.map do |profile|
            profile.slice("name", "stream", "version", "context", "arch") if profile["status"] == "enabled"
          end
          enabled_payload.compact!

          ::Katello::Pulp::Consumer.new(host.content_facet.uuid).upload_module_stream_profile(enabled_payload)
          host.import_module_streams(payload)
        rescue RestClient::ResourceNotFound
          Rails.logger.warn("Host with ID %s was not known to Pulp, continuing" % input[:host_id])
        end

        def import_deb_package_profile(host, profile)
          installed_deb_ids = profile.map do |item|
            ::Katello::InstalledDeb.find_or_create_by(name: item['name'], architecture: item['architecture'], version: item['version']).id
          end
          host.installed_deb_ids = installed_deb_ids
          host.save!
        rescue ActiveRecord::InvalidForeignKey # this happens if the host gets deleted in between the "find_by" and "import_package_profile"
          Rails.logger.warn("Host installed package list with ID %s was not able to be written to the DB (host likely is deleted), continuing" % host.id)
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
          elsif profiles.try(:has_key?, "deb_package_profile")
            # remove this when deb_package_profile API is removed
            payload = profiles.dig("deb_package_profile", "deb_packages") || []
            import_deb_package_profile(host, payload)
          else
            profiles.each do |profile|
              payload = profile["profile"]
              case profile["content_type"]
              when "rpm"
                UploadPackageProfile.upload(input[:host_id], payload)
              when "deb"
                import_deb_package_profile(host, payload)
              when "enabled_repos"
                host.import_enabled_repositories(payload)
              else
                import_module_streams(payload, host)
              end
            end
          end
        end
      end
    end
  end
end
