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

          content_type = ::Katello::RepositoryTypeManager.find_content_type(input[:options][:content_unit_type].downcase)
          units = content_type.model_class.where(:id => content_unit_ids)

          output[:pulp_tasks] = repo.backend_service(smart_proxy).remove_content(units)
        end
      end
    end
  end
end
