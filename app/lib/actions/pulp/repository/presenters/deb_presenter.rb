module Actions
  module Pulp
    module Repository
      module Presenters
        class DebPresenter < AbstractSyncPresenter
          def progress
            if items_total > 0
              items_done.to_f / items_total
            else
              0.01
            end
          end

          private

          def humanized_details
            res = ""

            if task_details
              sync_step = task_details.select { |step| step["step_type"] == "sync_step_unit_download" }.first
              if sync_step
                if sync_step["items_total"] > 0
                  res = "New packages: #{sync_step["num_processed"]}/#{sync_step["items_total"]}"
                else
                  res = _("No new packages.")
                end
              end
            end

            res
          end

          def size_summary
            helper = Object.new.extend(ActionView::Helpers::NumberHelper)
            if content_details[:state] == "IN_PROGRESS"
              "#{helper.number_to_human_size(size_done)}/#{helper.number_to_human_size(size_total)}"
            else
              helper.number_to_human_size(size_total)
            end
          end

          def task_progress
            sync_task[:progress_report]
          end

          def task_progress_details
            task_progress && task_progress[:deb_importer]
          end

          def task_details
            task_result_details || task_progress_details
          end

          def content_details
            task_details && task_details[:content]
          end

          def error_details
            content_details.nil? ? [] : content_details[:error_details]
          end

          def metadata_details
            task_details && task_details[:metadata]
          end

          def items_done
            task_details&.inject(0) { |sum, details| sum + details[:num_success].to_i } || 0
          end

          def items_total
            task_details&.inject(0) { |sum, details| sum + details[:items_total].to_i } || 0
          end

          def size_done
            size_total - content_details[:size_left]
          end

          def size_total
            (content_details && content_details[:size_total]).to_i
          end

          def cancelled?
            task_details.nil? ? false : task_details.values.map { |item| item['state'] }.include?('CANCELLED')
          end

          def content_started?
            content_details && content_details[:state] != 'NOT_STARTED'
          end

          def metadata_in_progress?
            metadata_details && metadata_details[:state] == 'IN_PROGRESS'
          end

          def metadata_error
            metadata_details && metadata_details[:error]
          end

          def pending?
            metadata_details.nil? || metadata_details['state'] == 'NOT_RUNNING'
          end
        end
      end
    end
  end
end
