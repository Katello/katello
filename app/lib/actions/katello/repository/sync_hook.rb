module Actions
  module Katello
    module Repository
      class SyncHook < Actions::Base
        def finalize
          ::Katello::Repository.find(input[:id]).sync_hook
        end
      end
    end
  end
end
