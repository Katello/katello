module Actions
  module Pulp
    module Repository
      class Refresh < Pulp::AbstractAsyncTask
        def plan(repository, options = {})
          options[:capsule_id] ||= SmartProxy.default_capsule!.id
          plan_self(:capsule_id => options[:capsule_id], :pulp_id => repository.pulp_id)
        end

        def invoke_external_task
          repo = ::Katello::Repository.find_by(:pulp_id => input[:pulp_id])
          if repo.nil?
            repo = ::Katello::ContentViewPuppetEnvironment.find_by(:pulp_id => input[:pulp_id])
            repo = repo.nonpersisted_repository
          end
          repo.backend_service(smart_proxy(input[:capsule_id])).refresh_if_needed
        end
      end
    end
  end
end
