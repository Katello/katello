module Actions
  module Pulp
    module Repository
      class CopyAllUnits < Pulp::AbstractAsyncTask
        def plan(target_repo, _smart_proxy, source_repo, options = {})
          filter_ids = options.fetch(:filters, nil)&.map(&:id)
          rpm_filenames = options.fetch(:rpm_filenames, nil)
          solve_dependencies = options.fetch(:solve_dependencies, false)

          plan_self(source_repo_id: source_repo.id,
                    target_repo_id: target_repo.id,
                    filter_ids: filter_ids,
                    solve_dependencies: solve_dependencies,
                    rpm_filenames: rpm_filenames)
        end

        def invoke_external_task
          source_repo = ::Katello::Repository.find(input[:source_repo_id])
          target_repo = ::Katello::Repository.find(input[:target_repo_id])
          filters = ::Katello::ContentViewFilter.where(:id => input[:filter_ids])

          source_repo.backend_service(SmartProxy.pulp_primary).copy_contents(target_repo,
                                                                            filters: filters,
                                                                            solve_dependencies: input[:solve_dependencies],
                                                                            rpm_filenames: input[:rpm_filenames])
        end
      end
    end
  end
end
