module Actions
  module Pulp
    module Repository
      class Destroy < Pulp::AbstractAsyncTask
        input_format do
          param :pulp_id
        end

        def invoke_external_task
          output[:pulp_tasks] = pulp_extensions.repository.delete(input[:pulp_id])
        end
      end
    end
  end
end
