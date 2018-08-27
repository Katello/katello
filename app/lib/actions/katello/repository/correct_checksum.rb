module Actions
  module Katello
    module Repository
      class CorrectChecksum < Actions::Base
        def plan(repo)
          plan_self(:repo_id => repo.id)
        end

        def finalize
          ::User.current = ::User.anonymous_admin
          repo = ::Katello::Repository.find(input[:repo_id])

          if repo.pulp_scratchpad_checksum_type &&
              repo.pulp_scratchpad_checksum_type != repo.source_repo_checksum_type
            repo.source_repo_checksum_type = repo.pulp_scratchpad_checksum_type
            repo.save!
          end
        ensure
          ::User.current = nil
        end
      end
    end
  end
end
