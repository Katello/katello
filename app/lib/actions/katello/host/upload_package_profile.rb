module Actions
  module Katello
    module Host
      class UploadPackageProfile < Actions::EntryAction
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
          profile = JSON.parse(input[:profile_string])
          #free the huge string from the memory
          input[:profile_string] = 'TRIMMED'.freeze

          host = ::Host.find_by(:id => input[:host_id])
          if host.nil?
            Rails.logger.warn("Host with ID %s not found, continuing" % input[:host_id])
          elsif host.content_facet.nil? || host.content_facet.uuid.nil?
            Rails.logger.warn("Host with ID %s has no content facet, continuing" % input[:host_id])
          else
            begin
              ::Katello::Pulp::Consumer.new(host.content_facet.uuid).upload_package_profile(profile)
              simple_packages = profile.map { |item| ::Katello::Pulp::SimplePackage.new(item) }
              host.import_package_profile(simple_packages)
            rescue RestClient::ResourceNotFound
              Rails.logger.warn("Host with ID %s was not known to Pulp, continuing" % input[:host_id])
            rescue ActiveRecord::InvalidForeignKey # this happens if the host gets deleted in between the "find_by" and "import_package_profile"
              Rails.logger.warn("Host installed package list with ID %s was not able to be written to the DB (host likely is deleted), continuing" % input[:host_id])
            end
          end
        end
      end
    end
  end
end
