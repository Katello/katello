module Actions
  module Katello
    module Repository
      class UpdateContentUrls < Actions::EntryAction
        def plan(content_to_update)
          concurrence do
            content_to_update.flat_map(&:repositories).each do |repo|
              plan_action(Katello::Repository::UpdateRedhatRepository, repo)
            end
          end
        end
      end
    end
  end
end
