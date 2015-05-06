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
          found_checksum = repo.pulp_checksum_type

          if found_checksum && repo.checksum_type != found_checksum
            repo.checksum_type = found_checksum
            repo.save!
          end
        ensure
          ::User.current = nil
        end
      end
    end
  end
end
