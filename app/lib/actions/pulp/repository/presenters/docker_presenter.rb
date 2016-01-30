module Actions
  module Pulp
    module Repository
      module Presenters
        class DockerPresenter < AbstractSyncPresenter
          def progress
            details = task_progress_details
            if details
              completion = 0.0
              completion += 0.1 if content_completed?(details("sync_step_metadata"))
              completion += 0.1 if content_completed?(details("get_local"))
              completion += 0.1 if content_completed?(details("sync_step_save"))
              download_details = details("sync_step_download")
              if content_completed?(download_details)
                completion += 0.7
              elsif content_started?(download_details) && items_total(download_details) > 0
                completion += 0.7 * items_done(download_details) / items_total(download_details)
              end
              completion
            else
              0.01
            end
          end

          private

          def humanized_details
            download_details = details("sync_step_download")
            ret = []
            ret << _("Cancelled.") if cancelled?

            if content_started?(download_details)
              if items_total(download_details) > 0
                ret << (_("New images: %{count}.") % {:count => count_summary})
              end
            elsif sync_task["state"] == "running"
              ret << _("Processing metadata")
            end

            ret << metadata_error if metadata_error
            ret.join("\n")
          end

          def count_summary
            download_details = details("sync_step_download")

            if download_details[:state] == "IN_PROGRESS"
              "#{items_done(download_details)}/#{items_total(download_details)}"
            else
              items_done(download_details)
            end
          end

          def details(step_type)
            task_progress_details && task_progress_details.find do |step|
              step[:step_type] == step_type
            end
          end

          def task_progress
            sync_task['progress_report']
          end

          def task_progress_details
            task_progress && task_progress['docker_importer']
          end

          def total
            task_progress_details
          end

          def items_done(content_details)
            content_details[:num_processed]
          end

          def items_total(content_details)
            content_details && content_details[:items_total].to_i
          end

          def content_started?(content_details)
            content_details && content_details[:state] != 'NOT_STARTED'
          end

          def content_completed?(content_details)
            content_details && content_details[:state] == 'FINISHED'
          end

          def pending?(_content_details)
            task_progress.nil? || task_progress['state'] == 'NOT_RUNNING'
          end

          def metadata_in_progress?
            sync_task && sync_task[:state] == 'started'
          end

          def metadata_error
            sync_task && sync_task[:state] == 'error' && sync_task[:error][:description]
          end
        end
      end
    end
  end
end
