module Actions
  module Pulp3
    module Orchestration
      module Repository
        class CopyAllUnits < Pulp3::Abstract
          # Copying all the units from the source repository version to the destination katello repository
          # if there are no filters, we can just reference the repository version and publication
          def plan(target_repo, smart_proxy, source_repositories, options = {})
            filter_ids = options.fetch(:filters, nil)&.map(&:id)
            rpm_filenames = options.fetch(:rpm_filenames, nil)
            solve_dependencies = options.fetch(:solve_dependencies, false)

            if filter_ids.present? || rpm_filenames.present? || source_repositories.length > 1
              sequence do
                if filter_ids.present? || rpm_filenames.present?
                  #if we are filtering, we need to copy from each repo with filters in place.  We also need to clear out everything in the repo
                  # which will be easier with https://pulp.plan.io/issues/4901
                  start_copying_from = 0
                  fail "Publish with filters are not currently supported"
                else
                  #if we are not filtering, copy the version to the cv repository, and the units for each additional repo
                  action = plan_action(Actions::Pulp3::Repository::CopyVersion, source_repositories.first, smart_proxy, target_repo)
                  plan_action(Actions::Pulp3::Repository::SaveVersion, target_repo, action.output[:pulp_tasks])
                  start_copying_from = 1 #since we're creating a new version from the first repo, start copying at the 2nd
                end

                copy_actions = []
                source_repositories[start_copying_from..-1].each do |source_repo|
                  copy_actions << plan_action(Actions::Pulp3::Repository::CopyContent,
                                              source_repo, smart_proxy, target_repo,
                                              filter_ids: filter_ids,
                                              solve_dependencies: solve_dependencies,
                                              rpm_filenames: rpm_filenames)
                end

                plan_action(Actions::Pulp3::Repository::SaveVersion, target_repo, copy_actions.last.output[:pulp_tasks])
              end
            else
              plan_self(source_version_repo_id: source_repositories.first.id,
                        target_repo_id: target_repo.id)
              target_repo.update_attributes!(version_href: source_repositories.first.version_href)
            end
          end

          def run
            #this is a 'simple' copy, so just reference version_href
            target_repo = ::Katello::Repository.find(input[:target_repo_id])
            source_repo = ::Katello::Repository.find(input[:source_version_repo_id])
            target_repo.update_attributes!(version_href: source_repo.version_href)
          end
        end
      end
    end
  end
end
