module Actions
  module Pulp3
    module Repository
      module Presenters
        class ContentUnitPresenter < AbstractSyncPresenter
          def progress
            total_units == 0 ? 0.01 : finished_units.to_f / total_units
          end

          private

          def humanized_details
            ret = []
            ret << _("Cancelled.") if cancelled?
            ret << _("New Content Units: %s") % finished_units
            ret.join("\n")
          end

          def total_units
            task_progress_details.try(:[], 'total') || 1
          end

          def finished_units
            task_progress_details.try(:[], 'done') || 0
          end

          def task_progress_details
            task_progress_report
          end

          def task_progress_report
            return nil unless sync_task
            progress_reports = sync_task['progress_reports']
            progress_reports.select! do |progress_report|
              if progress_report.key? 'message'
                progress_report['message'].include?("Parsing Metadata") # Decide which to track
              end
            end
            progress_reports.first
          end
        end
      end
    end
  end
end
