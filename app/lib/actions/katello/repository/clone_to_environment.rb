module Actions
  module Katello
    module Repository
      # Clones the contnet of the repository into the environment
      # effectively promotion the repository to the environment
      class CloneToEnvironment < Actions::Base
        include Actions::Katello::PulpSelector
        def plan(repository, environment)
          clone = find_or_build_environment_clone(repository, environment)

          sequence do
            if clone.new_record?
              plan_action(Repository::Create, clone, true, false)
            else
              #only clear if it should be empty, but its not
              plan_optional_pulp_action([Actions::Pulp::Repository::Clear], clone, SmartProxy.pulp_master)
              # Do we need to refresh distributors here?
              plan_optional_pulp_action([Actions::Pulp::Orchestration::Repository::RefreshIfNeeded], clone, SmartProxy.pulp_master)
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
