module Actions
  module Katello
    module Repository
      class DestroyMedium < Actions::Base
        def plan(repo)
          medium = Medium.find_medium(repo)
          medium.destroy! if medium
        end
      end
    end
  end
end
