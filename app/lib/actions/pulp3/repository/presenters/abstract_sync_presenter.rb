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

          def index_action
            plan = action.execution_plan
            index_step = plan.run_steps.find { |s| s.action_class == Actions::Katello::Repository::IndexContent }
            index_step&.action(plan)
          end

          def added_content_message
            if (content_added = index_action&.output&.[](:new_content))
              content_added = content_added.select { |_type, number| number > 0 }
              if content_added&.any?
                count_messages = content_added.map { |type, number| "#{type.to_s.humanize.pluralize}: #{number}" }
                _("Added %s") % count_messages.join(', ')
              else
                _("No content added.")
              end
            end
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
