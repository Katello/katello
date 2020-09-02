module Actions
  module Katello
    module Repository
      class PurgeEmptyContent < Pulp::AbstractAsyncTask
        input_format do
          param :id, Integer
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:id])
          repo.backend_service(SmartProxy.pulp_primary).purge_empty_contents
        end
      end
    end
  end
end
