module Actions
  module Pulp3
    module Orchestration
      module Repository
        class CopyAllUnits < Pulp3::AbstractAsyncTask
          # Copying all the units from the source repository version to the destination katello repository
          # if there are no filters, we can just reference the repository version and publication
          def plan(source_repo, _smart_proxy, target_repo, options = {})
            filter_ids = options.fetch(:filters, nil)&.map(&:id)
            rpm_filenames = options.fetch(:rpm_filenames, nil)
            solve_dependencies = options.fetch(:solve_dependencies, false)

            if filter_ids.present? || rpm_filenames.present?
              plan_self(source_repo_id: source_repo.id,
                                    target_repo_id: target_repo.id,
                                    filter_ids: filter_ids,
                                    solve_dependencies: solve_dependencies,
                                    rpm_filenames: rpm_filenames)
              fail 'not supported yet in pulp3'
            else
              target_repo.update_attributes!(version_href: source_repo.version_href)
            end
          end

          def invoke_external_task
          end
        end
      end
    end
  end
end
