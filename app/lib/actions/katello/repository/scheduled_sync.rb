module Actions
  module Katello
    module Repository
      class ScheduledSync < Sync
        def humanized_name
          _("Scheduled Synchronization")
        end

        def resource_locks
          :link
        end
      end
    end
  end
end
