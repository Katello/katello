module Actions
  module Pulp3
    module Repository
      class MultiCopyContent < Pulp3::AbstractAsyncTask
        def plan(extended_repo_map, smart_proxy, options)
          repo_id_map = {}

          extended_repo_map.each do |source_repos, dest_repo_map|
            repo_id_map[source_repos&.map(&:id)] = { :dest_repo => dest_repo_map[:dest_repo].id,
                                                     :filter_ids => dest_repo_map[:filters]&.map(&:id) }
          end

          plan_self(options.merge(:repo_id_map => repo_id_map, :smart_proxy_id => smart_proxy.id))
        end

        def invoke_external_task
          repo_id_map = {}

          input[:repo_id_map].each do |source_repo_ids, dest_repo_map|
            repo_id_map[JSON.parse(source_repo_ids)] = dest_repo_map
          end

          output[:pulp_tasks] = ::Katello::Repository.find(repo_id_map.values.first[:dest_repo]).backend_service(smart_proxy).copy_content_from_mapping(repo_id_map, input)
        end
      end
    end
  end
end
