module Actions
  module Katello
    module Product
      class RepositoriesGpgReset < Actions::AbstractAsyncTask
        def plan(product)
          key_id = product.gpg_key_id
          # Plan Repository::Update only for repositories which have different gpg key
          product.repositories.each do |repo|
            if repo.gpg_key_id != key_id
              plan_action(::Actions::Katello::Repository::Update,
                          repo,
                          :gpg_key_id => key_id)
            end
          end
        end
      end
    end
  end
end
