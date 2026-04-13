module Actions
  module Katello
    module Applicability
      class Scheduler < Actions::Base
        include ::Dynflow::Action::Singleton

        def queue
          ::Katello::HOST_TASKS_QUEUE
        end

        def run
          ::Katello::Applicability::Scheduler.drain_loop
        end

        def humanized_name
          _("Host applicability scheduler")
        end
      end
    end
  end
end
