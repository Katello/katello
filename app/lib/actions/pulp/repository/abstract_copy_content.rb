module Actions
  module Pulp
    module Repository
      class AbstractCopyContent < Pulp::AbstractAsyncTask
        input_format do
          param :source_pulp_id
          param :target_pulp_id
          param :clauses
          param :full_clauses
          param :override_config
          param :include_result
        end

        # @api override - pulp extension representing the content type to copy
        def content_extension
          fail NotImplementedError
        end

        def invoke_external_task
          optional = criteria
          optional[:override_config] = input[:override_config] if input[:override_config]
          content_extension.copy(input[:source_pulp_id],
                                 input[:target_pulp_id],
                                 optional)
        end

        def criteria
          if input[:full_clauses]
            input[:full_clauses]
          elsif input[:clauses]
            { filters: {:unit => input[:clauses] } }
          else
            {}
          end
        end

        def external_task=(external_task_data)
          external_task_data = [external_task_data] if external_task_data.is_a?(Hash)
          external_task_data = external_task_data.map { |task| task.except('result') } unless input[:include_result]
          super(external_task_data)
        end
      end
    end
  end
end
