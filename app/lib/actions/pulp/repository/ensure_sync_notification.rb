module Actions
  module Pulp
    module Repository
      class EnsureSyncNotification < Pulp::Abstract
        def run
          output[:results] = ::Katello::Repository.ensure_sync_notification
        end
      end
    end
  end
end
