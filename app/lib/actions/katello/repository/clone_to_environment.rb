module Actions
  module Katello
    module Repository
      # Clones the contnet of the repository into the environment
      # effectively promotion the repository to the environment
      class CloneToEnvironment < Actions::Base
        def plan(repository, environment)
          clone = find_or_build_environment_clone(repository, environment)

          sequence do
            if clone.new_record?
              plan_action(Repository::Create, clone, true, false, repository.ostree_branch_names)
            else
              plan_action(Repository::Clear, clone)
            end

            if repository.yum?
              plan_action(Repository::CloneYumContent, repository, clone, [], false)
            elsif repository.docker?
              plan_action(Repository::CloneDockerContent, repository, clone)
            elsif repository.ostree?
              plan_action(Repository::CloneOstreeContent, repository, clone)
            end
          end
        end

        # The environment clone clone of the repository is the one
        # visible for the systems in the environment
        def find_or_build_environment_clone(repository, environment)
          version = repository.content_view_version
          clone = version.content_view.get_repo_clone(environment, repository).first

          if clone
            clone = ::Katello::Repository.find(clone.id) # reload readonly object
            clone.update_attributes!(content_view_version_id: version.id)
          else
            clone = repository.build_clone(environment: environment, content_view: version.content_view)
          end
          return clone
        end
      end
    end
  end
end
