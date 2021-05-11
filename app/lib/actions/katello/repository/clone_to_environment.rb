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
              plan_action(Repository::Create, clone, true)
            end

            plan_action(::Actions::Katello::Repository::CloneContents, [repository], clone, :copy_contents => !clone.yum?)
          end
        end

        # The environment clone clone of the repository is the one
        # visible for the systems in the environment
        def find_or_build_environment_clone(repository, environment)
          version = repository.content_view_version
          clone = version.content_view.get_repo_clone(environment, repository).first

          if clone
            clone = ::Katello::Repository.find(clone.id) # reload readonly object
            clone.update!(content_view_version_id: version.id)
          else
            clone = repository.build_clone(environment: environment, content_view: version.content_view)
          end
          return clone
        end
      end
    end
  end
end
