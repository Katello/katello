module Actions
  module Katello
    module ContentCredential
      class Update < Actions::EntryAction
        def plan(gpg_key, gpg_key_params)
          action_subject gpg_key
          gpg_key.update!(gpg_key_params)
          gpg_key.repositories.each do |repository|
            if repository.deb?
              plan_action(::Actions::Katello::Repository::RefreshRepository, repository)
            end
          end
        end
      end
    end
  end
end
