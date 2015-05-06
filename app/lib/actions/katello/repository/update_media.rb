module Actions
  module Katello
    module Repository
      class UpdateMedia < Actions::Base
        def plan(repo)
          plan_self(:repo_id => repo.id)
        end

        def finalize
          repo = ::Katello::Repository.find(input[:repo_id])
          Medium.update_media(repo)
        end
      end
    end
  end
end
