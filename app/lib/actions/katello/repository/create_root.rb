module Actions
  module Katello
    module Repository
      class CreateRoot < Actions::EntryAction
        def plan(root, relative_path = nil)
          begin
            root.save!
          rescue ActiveRecord::RecordInvalid
            if root.is_container_push
              logger.warn("Skipping repository creation as container push repository already exists: #{root.container_push_name}")
              return
            end
          end
          repository = ::Katello::Repository.new(:environment => root.organization.library,
                                      :content_view_version => root.organization.library.default_content_view_version,
                                      :root => root)
          repository.container_repository_name = relative_path if root.docker? && root.is_container_push
          repository.relative_path = relative_path || repository.custom_repo_path
          repository.save!

          action_subject(repository)
          plan_action(::Actions::Katello::Repository::Create, repository)
        end

        def humanized_name
          _("Create")
        end
      end
    end
  end
end
