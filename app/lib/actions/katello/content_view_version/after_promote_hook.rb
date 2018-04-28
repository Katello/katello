module Actions
  module Katello
    module ContentViewVersion
      class AfterPromoteHook < Actions::Base
        def finalize
          ::Katello::ContentViewVersion.find(input[:id]).after_promote_hooks
        end
      end
    end
  end
end
