module Actions
  module Candlepin
    module Owner
      class Import < Candlepin::Abstract
        input_format do
          param :label
          param :path
          param :force
          param :upstream
        end

        def run
          options = input.slice(:force, :upstream)
          cp_response = JSON.parse(
            ::Katello::Resources::Candlepin::Owner.import(input[:label], input[:path], options)
          )
          output[:task] = cp_response # this also sets external_task
          output[:task_id] = cp_response['id']
        end
      end
    end
  end
end
