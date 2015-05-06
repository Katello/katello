module Actions
  module Pulp
    module Repository
      class AbstractRemoveContent < Pulp::AbstractAsyncTask
        input_format do
          param :pulp_id
          param :clauses
        end

        def invoke_external_task
          pulp_extensions.repository.unassociate_units(input[:pulp_id],
                                                       criteria)
        end

        # @api override - pulp extension representing the content to remove
        # e.g. pulp.extensions.rpm
        def content_extension
          fail NotImplementedError
        end

        def criteria
          { type_ids: [content_extension.content_type], filters: input[:clauses] }
        end

        def external_task=(external_task_data)
          external_task_data = [external_task_data] if external_task_data.is_a?(Hash)
          super(external_task_data.map { |task| task.except('result') })
        end
      end
    end
  end
end
