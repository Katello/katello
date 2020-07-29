module Actions
  module Pulp3
    module Repository
      module Presenters
        class RepairPresenter < Helpers::Presenter::Base
          def humanized_output
            if action.external_task
              humanized_details
            end
          end

          def progress
            total_units == 0 ? 0.1 : finished_units.to_f / total_units
          end

          private

          def repair_task
            tasks = action.external_task.select do |task|
              if task.key? 'name'
                task['name'].include?("repair_version")
              end
            end
            tasks.first
          end

          def cancelled?
            repair_task && repair_task['state'] == 'cancelled'
          end

          def task_result
            repair_task['result']
          end

          def task_result_details
            task_result && task_result['details']
          end

          def humanized_details
            ret = []
            ret << _("Cancelled.") if cancelled?
            ret << _("Total steps: ") + "#{finished_units}/#{total_units}"
            ret << "--------------------------------"
            progress_reports = repair_task.try(:[], 'progress_reports') || []
            progress_reports = progress_reports.sort_by { |pr| pr.try(:[], 'message') }
            progress_reports.each do |pr|
              done = pr.try(:[], 'done')
              total = pr.try(:[], 'total') || pr.try(:[], 'done')
              unless done.nil? || total.nil?
                ret << _(pr.try(:[], 'message') + ": #{done}/#{total}")
              end
            end

            ret.join("\n")
          end

          def total_units
            total_unit = 0
            progress_reports = repair_task.try(:[], 'progress_reports') || []
            progress_reports.each do |pr|
              total = pr.try(:[], 'total')
              total = pr.try(:[], 'done') if total.nil?
              unless total.nil?
                total_unit += total.to_i
              end
            end
            total_unit
          end

          def finished_units
            finished_unit = 0
            progress_reports = repair_task.try(:[], 'progress_reports') || []
            progress_reports.each do |pr|
              done = pr.try(:[], 'done')
              unless done.nil?
                finished_unit += done.to_i
              end
            end
            finished_unit
          end
        end
      end
    end
  end
end
