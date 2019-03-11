module Actions
  module Pulp
    module Repository
      class Refresh < Pulp::Abstract
        input_format do
          param :capsule_id
          param :pulp_id
        end

        def plan(repository, options = {})
          options[:capsule_id] ||= SmartProxy.default_capsule!.id
          plan_self(:capsule_id => options[:capsule_id], :pulp_id => repository.pulp_id)
        end

        def run
          repo = ::Katello::Repository.find_by(:pulp_id => input[:pulp_id])
          if repo.nil?
            repo = ::Katello::ContentViewPuppetEnvironment.find_by(:pulp_id => input[:pulp_id])
            repo = repo.nonpersisted_repository
          end
          output[:results] = repo.backend_service(smart_proxy(input[:capsule_id])).refresh
        end
      end
    end
  end
end
