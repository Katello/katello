module Actions
  module Katello
    module ContentView
      class UpdateHostStatus < Actions::Base
        def humanized_name
          _("Update the status of hosts subscribed to the content view.")
        end

        def queue
          ::Katello::HOST_TASKS_QUEUE
        end

        def plan(content_view, environment)
          plan_self(:content_view_id => content_view.id, :environment_id => environment.id)
        end

        def run
          environment = ::Katello::KTEnvironment.find(input[:environment_id])
          ::Katello::ContentView.find(input[:content_view_id]).update_host_statuses(environment)
        end
      end
    end
  end
end
