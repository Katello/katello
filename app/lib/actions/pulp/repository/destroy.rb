module Actions
  module Pulp
    module Repository
      class Destroy < Pulp::AbstractAsyncTask
        input_format do
          param :repository_id
          param :capsule_id
          param :content_view_puppet_environment_id
        end

        def plan(repository, smart_proxy = SmartProxy.pulp_master!)
          if repository.is_a?(::Katello::ContentViewPuppetEnvironment)
            plan_self(:content_view_puppet_environment_id => repository.id, :capsule_id => smart_proxy.id)
          else
            plan_self(:repository_id => repository.id, :capsule_id => smart_proxy.id)
          end
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
          capsule = input[:capsule_id] ? smart_proxy(input[:capsule_id]) : SmartProxy.pulp_master
          output[:pulp_tasks] = repo.backend_service(capsule).delete
        end
      end
    end
  end
end
