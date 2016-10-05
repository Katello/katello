module Actions
  module Pulp
    module Repository
      module Presenters
        class OstreePresenter < AbstractSyncPresenter
          def progress
            return 0.01 unless task_progress_details

            completion = 0.0
            completion += 0.2 if content_completed?(details("import_create_repository"))

            if content_completed?(details("import_pull"))
              completion += 0.5
            end
            completion += 0.3 if content_completed?(details("import_add_unit"))
            completion
          end

          private

          def fetch_pull_ratio(content_details)
            # looks like "details": "fetching 24980/46836 53%",
            fetch_details_line = content_details["details"]
            ret = "0"
            if fetch_details_line[-1] == "%"
              ret = fetch_details_line.split[-2] # "24980/46836"
            end
            ret
          end

          def humanized_details
            ret = []
            ret << _("Cancelled") if cancelled?

            if pending?
              ret << case current_step["step_type"]
                     when "import_create_repository"
                       _("Creating local repository")
                     when "import_pull"
                       _("Pulling remote branches. Downloaded %s units." % fetch_pull_ratio(details("import_pull")))
                     when "import_add_unit"
                       _("Adding content units")
                     end
            end

            if task_result
              ret << _("Branches updated")
            end

            ret << sync_error if sync_error
            ret.join("\n")
          end

          def details(step_type)
            task_progress_details.find do |step|
              step[:step_type] == step_type
            end
          end

          def content_completed?(content_details)
            content_details && content_details[:state] == 'FINISHED'
          end

          def task_progress
            sync_task['progress_report']
          end

          def task_progress_details
            task_progress && task_progress['ostree_web_importer']
          end

          def pending?
            sync_task["state"] == 'running'
          end

          def current_step
            task_progress_details.detect { |step| step["state"] == "IN_PROGRESS" }
          end

          def finished?
            sync_task["state"] == 'finished'
          end

          def sync_error
            task_result && task_result["error_message"]
          end
        end
      end
    end
  end
end
