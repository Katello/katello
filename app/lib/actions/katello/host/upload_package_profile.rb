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
          Rails.logger.info "DYNFLOW **********************************"
          host = ::Host::Managed.find(input[:host_id])
          ::Katello::Candlepin::PackageProfileUploader.upload(host: host, profile_string: input[:profile_string])
        end
      end
    end
  end
end
