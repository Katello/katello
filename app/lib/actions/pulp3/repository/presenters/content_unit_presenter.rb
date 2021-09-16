module Actions
  module Pulp3
    module Repository
      module Presenters
        class ContentUnitPresenter < AbstractSyncPresenter
          def progress
            total_units == 0 ? 0.1 : finished_units.to_f / total_units
          end

          private

          def humanized_details
            ret = []
            ret << _("Cancelled.") if cancelled?
            ret << added_content_message
            if total_units == 0
              ret << _("Waiting to start.")
            else
              ret << _("Total steps: ") + "#{finished_units}/#{total_units}"
            end
            ret << "--------------------------------"
            progress_reports = sync_task.try(:[], 'progress_reports') || []
            progress_reports = progress_reports.sort_by { |pr| pr.try(:[], 'message') }
            progress_reports.each do |pr|
              done = pr.try(:[], 'done')
              total = pr.try(:[], 'total') || pr.try(:[], 'done')
              unless done.nil? || total.nil?
                ret << _(pr.try(:[], 'message') + ": #{done}/#{total}")
              end
            end

            ret.compact.join("\n")
          end

          def total_units
            total_unit = 0
            progress_reports = sync_task.try(:[], 'progress_reports') || []
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
            progress_reports = sync_task.try(:[], 'progress_reports') || []
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
