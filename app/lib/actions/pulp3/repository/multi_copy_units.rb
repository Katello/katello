module Actions
  module Pulp3
    module Repository
      class MultiCopyUnits < Pulp3::AbstractAsyncTask
        # repo_map example: {
        #   [<source_repo_ids>]: {
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
                      smart_proxy_id: SmartProxy.pulp_primary.id).output
            plan_action(Pulp3::Repository::SaveVersions, repo_map.values.pluck(:dest_repo),
                        tasks: action_output[:pulp_tasks]).output
          end
        end

        def invoke_external_task
          unit_hrefs = []
          repo_map = {}

          input[:repo_map].each do |source_repo_ids, dest_repo_map|
            repo_map[JSON.parse(source_repo_ids)] = dest_repo_map
          end

          if input[:unit_map][:errata].any?
            unit_hrefs << ::Katello::RepositoryErratum.
              joins("inner join katello_errata on katello_repository_errata.erratum_id = katello_errata.id").
              where("katello_repository_errata.repository_id in (#{repo_map.keys.join(',')}) and
                    katello_errata.id in (#{input[:unit_map][:errata].join(",")})").map(&:erratum_pulp3_href)
          end

          if input[:unit_map][:debs].any?
            unit_hrefs << ::Katello::Deb.where(:id => input[:unit_map][:debs]).map(&:pulp_id)
          end

          if input[:unit_map][:rpms].any?
            unit_hrefs << ::Katello::Rpm.where(:id => input[:unit_map][:rpms]).map(&:pulp_id)
          end
          unit_hrefs.flatten!

          repo_map.each do |_source_repos, dest_repo_map|
            dest_repo_map[:content_unit_hrefs] = unit_hrefs
          end

          target_repo = ::Katello::Repository.find(repo_map.values.first[:dest_repo])
          unless unit_hrefs.flatten.empty?
            output[:pulp_tasks] = target_repo.backend_service(SmartProxy.pulp_primary).multi_copy_units(repo_map, input[:dependency_solving])
          end
        end
      end
    end
  end
end
