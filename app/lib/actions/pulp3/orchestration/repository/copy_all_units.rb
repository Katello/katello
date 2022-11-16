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
                  copy_action = plan_action(Actions::Pulp3::Repository::CopyContent, source_repositories.first, smart_proxy, target_repo,
                                            filter_ids: filter_ids, solve_dependencies: solve_dependencies,
                                            rpm_filenames: rpm_filenames, remove_all: true)
                  plan_action(Actions::Pulp3::Repository::SaveVersion, target_repo, tasks: copy_action.output[:pulp_tasks])
                else
                  #if we are not filtering, copy the version to the cv repository, and the units for each additional repo
                  action = plan_action(Actions::Pulp3::Repository::CopyVersion, source_repositories.first, smart_proxy, target_repo)
                  plan_action(Actions::Pulp3::Repository::SaveVersion, target_repo, tasks: action.output[:pulp_tasks])
                  copy_actions = []
                  #since we're creating a new version from the first repo, start copying at the 2nd
                  source_repositories[1..-1].each do |source_repo|
                    # TODO: In a future refactor, can :copy_all be utilized?  Filters should not be needed in this code segment.
                    copy_actions << plan_action(Actions::Pulp3::Repository::CopyContent, source_repo, smart_proxy, target_repo,
                                                filter_ids: filter_ids, solve_dependencies: solve_dependencies,
                                                rpm_filenames: rpm_filenames, remove_all: false)
                  end
                  plan_action(Actions::Pulp3::Repository::SaveVersion, target_repo, tasks: copy_actions.last.output[:pulp_tasks])
                end
              end
            else
              plan_self(source_version_repo_id: source_repositories.first.id,
                        target_repo_id: target_repo.id)
              target_repo.update!(version_href: source_repositories.first.version_href)
            end
          end

          def run
            #this is a 'simple' copy, so just reference version_href
            target_repo = ::Katello::Repository.find(input[:target_repo_id])
            source_repo = ::Katello::Repository.find(input[:source_version_repo_id])
            target_repo.update!(version_href: source_repo.version_href)
          end
        end
      end
    end
  end
end
