module Actions
  module Pulp3
    module Repository
      class RemoveUnits < Pulp3::AbstractAsyncTask
        def plan(repository, smart_proxy, options)
          plan_self(repository_id: repository.id,
                    smart_proxy_id: smart_proxy.id,
                    options: options)
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          content_unit_ids = input[:options][:contents]
          file_units = ::Katello::RepositoryFile.where(
            id: content_unit_ids,
            repository_id: repo.id)
          content_units = ::Katello::FileUnit.find(file_units.map(&:file_id))
          output[:pulp_tasks] = repo.backend_service(smart_proxy).remove_content(content_units)
        end
      end
    end
  end
end
