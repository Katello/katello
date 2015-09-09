module Actions
  module Pulp
    module Repository
      module Presenters
        class PuppetPresenter < AbstractSyncPresenter
          def progress
            total_count == 0 ? 0 : finished_count.to_f / total_count
          end

          private

          def humanized_details
            ret = []
            ret << _("Cancelled.") if cancelled?

            if total_count > 0
              ret << (_("Total module count: %s.") % [total_count])
            end

            if error_count > 0
              ret << n_("Failed to download %s module.", "Failed to download %s modules.",
                        error_count) % error_count
            end
            ret.join("\n")
          end

          def finished_count
            return 0 unless task_progress_details.key?('modules')
            task_progress_details['modules']['finished_count']
          end

          def total_count
            return 0 unless task_progress_details.key?('modules')
            return 0 if task_progress_details['modules']['total_count'].nil?
            task_progress_details['modules']['total_count']
          end

          def error_count
            return 0 if !task_result_details || !task_result_details['error_count']
            task_result_details['error_count']
          end

          def task_progress
            sync_task['progress_report']
          end

          def task_progress_details
            task_progress['puppet_importer'] || task_progress
          end
        end
      end
    end
  end
end
