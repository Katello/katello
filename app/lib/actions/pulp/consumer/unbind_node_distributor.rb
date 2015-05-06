module Actions
  module Pulp
    module Consumer
      class UnbindNodeDistributor < AbstractNodeDistributorTask
        input_format do
          param :consumer_uuid, String
          param :repo_id, String
        end

        def invoke_external_task
          pulp_resources.consumer.unbind(input[:consumer_uuid],
                                         input[:repo_id],
                                         distributor['id'])
        rescue  RestClient::ResourceNotFound
          Rails.logger.error("404 on consumer unbind.")
          return []
        end
      end
    end
  end
end
