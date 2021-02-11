module Actions
  module Candlepin
    module Owner
      class Import < Candlepin::AbstractAsyncTask
        input_format do
          param :label
          param :path
          param :force
          param :upstream
        end

        def invoke_external_task
          options = input.slice(:force, :upstream)
          cp_response = JSON.parse(
            ::Katello::Resources::Candlepin::Owner.import(input[:label], input[:path], options)
          )
          output[:task] = cp_response
          output[:task_id] = cp_response['id']
          poll_external_task # this return value sets external_task for future calls
        end

      end
    end
  end
end
