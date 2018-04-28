module Actions
  module Katello
    module ContentViewVersion
      class BeforePromoteHook < Actions::Base
        def finalize
          ::Katello::ContentViewVersion.find(input[:id]).before_promote_hooks
        end
      end
    end
  end
end
