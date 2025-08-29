module Actions
  module Katello
    module ContentView
      class Create < Actions::Base
        def plan(content_view, environment_ids = [])
          content_view.save!
          if content_view.rolling?
            new_version = content_view.create_new_version
            if environment_ids.any?
              ::Katello::KTEnvironment.where(id: environment_ids).each do |environment|
                plan_action(AddToEnvironment, new_version, environment)
              end
            end
            repository_ids = content_view.repository_ids
            if repository_ids.any?
              content_view.reload
              plan_action(AddRollingRepoClone, content_view, repository_ids, environment_ids)
            end
          end
        end

        def humanized_name
          _("Create content view")
        end
      end
    end
  end
end
