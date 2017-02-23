module Actions
  module Pulp
    module Repository
      class Download < Pulp::AbstractAsyncTask
        input_format do
          param :pulp_id
          param :options
        end

        def invoke_external_task
          output[:pulp_tasks] = pulp_resources.repository.download(input[:pulp_id], input[:options])
        end
      end
    end
  end
end
