module Actions
  module Katello
    module Repository
      class CreateContainerPushRoot < Actions::EntryAction
        def plan(root, relative_path = nil)
          repository = ::Katello::Repository.new(:environment => root.organization.library, :content_view_version => root.organization.library.default_content_view_version, :root => root)
          #Container push may concurrently call root add several times before the db can update.
          # If the root already exists, we can skip the creation of the root and repository.
          # We acquire a lock on the product to ensure that the root is not created multiple times by different workers.

          root.product.with_lock do
            begin
              root.save!
            rescue ActiveRecord::RecordInvalid => e
              if root.is_container_push && e.message.include?("Name has already been taken for this product")
                Rails.logger.debug("Skipping root repository creation as container push root repository already exists: #{root.container_push_name}")
                return
              end
              raise e
            end
            repository.container_repository_name = relative_path if root.docker? && root.is_container_push
            repository.relative_path = relative_path || repository.custom_repo_path
            begin
              repository.save!
            rescue ActiveRecord::RecordInvalid => e
              if root.is_container_push && e.message.include?("Container Repository Name") && e.message.include?("conflicts with an existing repository")
                Rails.logger.debug("Skipping repository creation as container push repository already exists: #{root.container_push_name}")
                return
              end
              raise e
            end
          end

          action_subject(repository)
          plan_action(::Actions::Katello::Repository::Create, repository)
        end

        def humanized_name
          _("Create Container Push Repository Root")
        end
      end
    end
  end
end
