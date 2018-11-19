module Actions
  module Katello
    module GpgKey
      class Update < Actions::EntryAction
        def plan(gpg_key, gpg_key_params)
          action_subject gpg_key
          gpg_key.update_attributes!(gpg_key_params)
          gpg_key.repositories.each do |repository|
            if repository.content_type == ::Katello::Repository::DEB_TYPE
              plan_action(::Actions::Katello::Repository::RefreshRepository, repository)
            end
          end
        end
      end
    end
  end
end
