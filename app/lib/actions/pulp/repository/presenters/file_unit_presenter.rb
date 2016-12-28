module Actions
  module Pulp
    module Repository
      module Presenters
        class FileUnitPresenter < AbstractSyncPresenter
          def progress
            total_bytes == 0 ? 0.01 : finished_bytes.to_f / total_bytes
          end

          private

          def humanized_details
            ret = []
            ret << _("Cancelled.") if cancelled?
            ret << _("New Files: %s") % num_isos
            ret.join("\n")
          end

          def num_isos
            task_progress_details && task_progress_details['num_isos'] || 0
          end

          def total_bytes
            task_progress_details && task_progress_details['total_bytes'] || 0
          end

          def finished_bytes
            task_progress_details && task_progress_details['finished_bytes'] || 0
          end

          def task_progress_details
            task_progress && task_progress['iso_importer']
          end

          def task_progress
            sync_task['progress_report']
          end
        end
      end
    end
  end
end
