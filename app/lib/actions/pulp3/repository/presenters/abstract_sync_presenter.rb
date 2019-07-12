module Actions
  module Pulp3
    module Repository
      module Presenters
        class AbstractSyncPresenter < Helpers::Presenter::Base
          def humanized_output
            if action.external_task
              humanized_details
            end
          end

          private

          def humanized_details
            fail NotImplementedError
          end

          def sync_task
            tasks = action.external_task.select do |task|
              if task.key? 'name'
                task['name'].include?("sync")
              end
            end
            tasks.first
          end

          def cancelled?
            sync_task && sync_task['state'] == 'cancelled'
          end

          def task_result
            sync_task['result']
          end

          def task_result_details
            task_result && task_result['details']
          end
        end
      end
    end
  end
end
