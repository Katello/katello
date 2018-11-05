module Actions
  module Pulp
    module Repository
      class Refresh < Pulp::Abstract
        input_format do
          param :capsule_id
          param :pulp_id
        end

        def plan(repository, options = {})
          plan_self(:capsule_id => options[:capsule_id], :pulp_id => repository.pulp_id)
        end

        def run
          repo = ::Katello::Repository.find_by(:pulp_id => input[:pulp_id])
          output[:results] = repo.backend_service(smart_proxy(input[:capsule_id])).refresh
        end
      end
    end
  end
end
