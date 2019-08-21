module Actions
  module Pulp
    module Repository
      class ImportUpload < Pulp::AbstractAsyncTask
        def plan(repo, smart_proxy, options)
          plan_self(:options => options)
        end

        def run
          output[:pulp_tasks] = [pulp_resources.content.import_into_repo(input[:options][:pulp_id],
                                                   input[:options][:unit_type_id],
                                                   input[:options][:upload_id],
                                                   input[:options][:unit_key],
                                                   unit_metadata: input[:options][:unit_metadata] || {})]
        end
      end
    end
  end
end
