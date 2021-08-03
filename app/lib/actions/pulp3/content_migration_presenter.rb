require 'katello/content_migration_progress'

module Actions
  module Pulp3
    class ContentMigrationPresenter < Helpers::Presenter::Base
      def initialize(migration_action)
        @migration_action = migration_action
      end

      def humanized_output
        if !@migration_action.done?
          ContentMigrationTaskPresenter.new(@migration_action).humanized_output
        else
          task = ForemanTasks::Task.find_by(:external_id => @migration_action.execution_plan_id)
          ::Katello::ContentMigrationProgress.find_by(:task_id => task.id)&.progress_message
        end
      end

      class ContentMigrationTaskPresenter
        def initialize(action)
          @action = action
        end

        def task_progress_reports
          if @action.pulp_tasks.empty?
            []
          else
            @action.pulp_tasks[0].progress_reports
          end
        end

        def task_group_progress_reports
          if @action.task_groups.empty?
            []
          else
            @action.task_groups[0].group_progress_reports
          end
        end

        def humanized_output
          report = task_progress_reports.find { |current| current['state'] == 'running' && current['total'] != 0 }
          report ||= task_group_progress_reports.find { |current| current['total'] != 0 && current['done'] != current['total'] }

          if !report.blank? && report['total'] != 0
            "#{report['message']} #{report['done']}/#{report['total']}"
          elsif report
            report['message']
          elsif task_progress_reports.empty?
            "Content migration starting. These steps may take a while to complete. " \
            "Refer to `foreman-maintain content migration-stats` for an estimate."
          else
            "Initial Migration steps complete."
          end
        rescue
          ""
        end
      end
    end
  end
end
