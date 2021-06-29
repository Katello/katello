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
          host = ::Host.find_by(:id => input[:host_id])
          ::Katello::Host::ProfilesUploader.upload(
            host: host,
            profile_string: input[:profile_string]
          )
          ::Katello::Host::ContentFacet.trigger_applicability_generation(input[:host_id])
        end
      end
    end
  end
end
