module Actions
  module Katello
    module ContentView
      class Create < Actions::Base
        def plan(content_view)
          content_view.save!
          if content_view.rolling?
            plan_action(AddToEnvironment, content_view.create_new_version, content_view.organization.library)
            repository_ids = content_view.repository_ids
            if repository_ids.any?
              content_view.reload
              plan_action(AddRollingRepoClone, content_view, repository_ids)
            end
          end
        end

        def humanized_name
          _("Create")
        end
      end
    end
  end
end
