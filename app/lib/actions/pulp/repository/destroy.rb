module Actions
  module Pulp
    module Repository
      class Destroy < Pulp::AbstractAsyncTask
        input_format do
          param :pulp_id
          param :capsule_id
        end

        def invoke_external_task
          output[:pulp_tasks] = pulp_extensions.repository.delete(input[:pulp_id])
        rescue RestClient::ResourceNotFound
          Rails.logger.warn("Tried to delete repository #{input[:pulp_id]}, but it did not exist.")
          []
        end
      end
    end
  end
end
