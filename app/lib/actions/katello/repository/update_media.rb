module Actions
  module Katello
    module Repository
      class UpdateMedia < Actions::Base
        input_format do
          param :repo_id
          param :contents_changed
        end

        def finalize
          repo = ::Katello::Repository.find(input[:repo_id])
          Medium.update_media(repo)
        end
      end
    end
  end
end
