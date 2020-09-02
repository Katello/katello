module Actions
  module Pulp
    module Repository
      class Destroy < Pulp::AbstractAsyncTask
        input_format do
          param :repository_id
          param :capsule_id
          param :content_view_puppet_environment_id
        end

        def invoke_external_task
          begin
            if input[:content_view_puppet_environment_id]
              repo = ::Katello::ContentViewPuppetEnvironment.find(input[:content_view_puppet_environment_id]).nonpersisted_repository
            else
              repo = ::Katello::Repository.find(input[:repository_id])
            end
          rescue ActiveRecord::RecordNotFound
            Rails.logger.warn("Tried to delete repository #{input[:repository_id]}, but it did not exist.")
            return []
          end
          capsule = input[:capsule_id] ? smart_proxy(input[:capsule_id]) : SmartProxy.pulp_primary
          output[:pulp_tasks] = repo.backend_service(capsule).delete
        end
      end
    end
  end
end
