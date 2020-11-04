module Actions
  module Katello
    module Host
      class UploadPackageProfile < Actions::EntryAction
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

        def self.upload(host_id, profile)
          host = ::Host.find_by(:id => host_id)
          if host.nil?
            Rails.logger.warn("Host with ID %s not found, continuing" % host_id)
          elsif host.content_facet.nil? || host.content_facet.uuid.nil?
            Rails.logger.warn("Host with ID %s has no content facet, continuing" % host_id)
          else
            begin
              unless SmartProxy.pulp_primary&.pulp3_repository_type_support?(::Katello::Repository::YUM_TYPE)
                ::Katello::Pulp::Consumer.new(host.content_facet.uuid).upload_package_profile(profile)
              end
              simple_packages = profile.map { |item| ::Katello::Pulp::SimplePackage.new(item) }
              host.import_package_profile(simple_packages)
            rescue RestClient::ResourceNotFound
              Rails.logger.warn("Host with ID %s was not known to Pulp, continuing" % host_id)
            rescue ActiveRecord::InvalidForeignKey # this happens if the host gets deleted in between the "find_by" and "import_package_profile"
              Rails.logger.warn("Host installed package list with ID %s was not able to be written to the DB (host likely is deleted), continuing" % host_id)
            end
          end
        end

        def run
          profile = JSON.parse(input[:profile_string])
          #free the huge string from the memory
          input[:profile_string] = 'TRIMMED'.freeze
          UploadPackageProfile.upload(input[:host_id], profile)
        end
      end
    end
  end
end
