module Actions
  module Katello
    module Host
      class UpdateDebPackageProfile < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(host, deb_packages)
          action_subject host

          sequence do
            plan_self(:host_id => host.id, :hostname => host.name, :deb_packages => deb_packages)
            plan_action(GenerateApplicability, [host])
          end
        end

        def humanized_name
          if input.try(:[], :hostname)
            _("Deb Package Profile Update for %s") % input[:hostname]
          else
            _('Deb Package Profile Update')
          end
        end

        def resource_locks
          :link
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        def self.update(host_id, profile)
          host = ::Host.find_by(:id => host_id)
          if host.nil?
            Rails.logger.warn("Host with ID %s not found, continuing" % host_id)
          else
            begin
              installed_deb_ids = profile.map do |item|
                ::Katello::InstalledDeb.find_or_create_by(name: item['name'], architecture: item['architecture'], version: item['version']).id
              end
              host.installed_deb_ids = installed_deb_ids
              host.save!
            rescue ActiveRecord::InvalidForeignKey # this happens if the host gets deleted in between the "find_by" and "import_package_profile"
              Rails.logger.warn("Host installed package list with ID %s was not able to be written to the DB (host likely is deleted), continuing" % host_id)
            end
          end
        end

        def run
          deb_packages = input[:deb_packages]
          #free the huge string from the memory
          input[:deb_packages] = 'TRIMMED'.freeze
          UpdateDebPackageProfile.update(input[:host_id], deb_packages)
        end
      end
    end
  end
end
