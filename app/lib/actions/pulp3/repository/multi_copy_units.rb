module Actions
  module Pulp3
    module Repository
      class MultiCopyUnits < Pulp3::AbstractAsyncTask
        # repo_map example: {
        #   <source_repo_id>: {
        #     dest_repo: <dest_repo_id>,
        #     base_version: <base_version>
        #   }
        # }
        def plan(repo_map, unit_map, options = {})
          if unit_map.values.flatten.any?
            action_output = plan_self(repo_map: repo_map,
                      unit_map: unit_map,
                      dependency_solving: options[:dependency_solving],
                      incremental_update: options[:incremental_update],
                      smart_proxy_id: SmartProxy.pulp_master.id).output
            plan_action(Pulp3::Repository::SaveVersions, repo_map.values.pluck(:dest_repo),
                        tasks: action_output[:pulp_tasks]).output
          end
        end

        def invoke_external_task
          unit_hrefs = []
          repo_map = input[:repo_map]

          if input[:unit_map][:errata].any?
            unit_hrefs << ::Katello::RepositoryErratum.
              joins("inner join katello_errata on katello_repository_errata.erratum_id = katello_errata.id").
              where("katello_repository_errata.repository_id in (#{repo_map.keys.join(',')}) and
                    katello_errata.id in (#{input[:unit_map][:errata].join(",")})").map(&:erratum_pulp3_href)
          end

          if input[:unit_map][:rpms].any?
            unit_hrefs << ::Katello::Rpm.where(:id => input[:unit_map][:rpms]).map(&:pulp_id)
          end

          # TODO: Fix this workaround by refactoring copy_units after general content view dep solving is refactored
          source_repo = ::Katello::Repository.find(repo_map.keys.first)
          target_repo = ::Katello::Repository.find(repo_map.values.first[:dest_repo])
          dest_base_version = repo_map.values.first[:base_version]
          repo_map.delete(repo_map.keys.first)
          # FIXME: Need to handle unit_hrefs being empty properly.  Fall back to original CVV?
          # Note: Falling back to the original CVV repo versions would match up with Pulp 2's behavior
          unless unit_hrefs.flatten.empty?
            output[:pulp_tasks] = target_repo.backend_service(SmartProxy.pulp_master).copy_units(source_repo, unit_hrefs.flatten, input[:dependency_solving], dest_base_version, repo_map)
          end
        end
      end
    end
  end
end
