module Actions
  module Katello
    module Host
      class UploadProfiles < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def queue
          ::Katello::HOST_TASKS_QUEUE
        end

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

        def self.upload_modules_to_pulp(available_streams, host)
          query_name_streams = available_streams.map do |profile|
            ::Katello::ModuleStream.where(profile.slice(:name, :stream))
          end

          updated_profiles = []
          unless query_name_streams.empty?
            query_name_streams = query_name_streams.inject(&:or)

            bound_library_instances = host.content_facet.bound_repositories.map(&:library_instance_or_self)
            query = ::Katello::ModuleStream.in_repositories(bound_library_instances).
                                            select(:name, :stream, :version, :context, :arch).
                                              merge(query_name_streams)

            updated_profiles = query.map do |module_stream|
              module_stream.slice(:name, :stream, :version, :context, :arch)
            end
          end

          # We also need to pass module streams that are not found in the ModuleStream table
          # but are present on the content host
          unassociated_profiles = available_streams.select do |profile|
            updated_profiles.none? { |p| p[:name] == profile[:name] && p[:stream] == profile[:stream] }
          end

          module_stream_profile = updated_profiles + unassociated_profiles

          unless module_stream_profile.empty?
            begin
              ::Katello::Pulp::Consumer.new(host.content_facet.uuid).
                upload_module_stream_profile(module_stream_profile)
            rescue RestClient::ResourceNotFound
              Rails.logger.warn("Host with ID %s was not known to Pulp, continuing" % host.id)
            end
          end
        end

        def import_module_streams(payload, host)
          enabled_payload = payload.map do |profile|
            profile.slice("name", "stream", "version", "context", "arch").with_indifferent_access if profile["status"] == "enabled"
          end
          enabled_payload.compact!

          UploadProfiles.upload_modules_to_pulp(enabled_payload, host)
          host.import_module_streams(payload)
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
            module_streams = []
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
                module_streams << payload
              end
            end

            module_streams.each do |module_stream_payload|
              import_module_streams(module_stream_payload, host)
            end
          end
        end
      end
    end
  end
end
