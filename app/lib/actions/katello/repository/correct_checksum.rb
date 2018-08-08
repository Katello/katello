module Actions
  module Katello
    module Repository
      class CorrectChecksum < Actions::Base
        def plan(repo)
          plan_self(:repo_id => repo.id)
        end

        def finalize
          ::User.current = ::User.anonymous_admin
          root = ::Katello::Repository.find(input[:repo_id]).root

          if root.pulp_scratchpad_checksum_type &&
              root.pulp_scratchpad_checksum_type != root.source_repo_checksum_type
            root.source_repo_checksum_type = root.pulp_scratchpad_checksum_type
            root.save!
          end
        ensure
          ::User.current = nil
        end
      end
    end
  end
end
