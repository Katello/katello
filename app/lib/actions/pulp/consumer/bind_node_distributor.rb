module Actions
  module Pulp
    module Consumer
      class BindNodeDistributor < AbstractNodeDistributorTask
        input_format do
          param :consumer_uuid, String
          param :repo_id, String
          param :bind_options, Hash
        end

        def invoke_external_task
          pulp_resources.consumer.bind(input[:consumer_uuid],
                                       input[:repo_id],
                                       distributor['id'],
                                       input[:bind_options])
        end
      end
    end
  end
end
