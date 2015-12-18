module Actions
  module Pulp
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
              if task.key? 'tags'
                task['tags'].include?("pulp:action:sync")
              else
                # workaround for https://bugzilla.redhat.com/show_bug.cgi?id=1131537
                # as the sync plan tasks don't have tags in pulp
                task['result'] &&
                    task['result']['importer_type_id'].to_s =~ /_importer$/
              end
            end
            tasks.first
          end

          def cancelled?
            sync_task['state'] == 'canceled'
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
