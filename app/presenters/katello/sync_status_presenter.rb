module Katello
  class SyncStatusPresenter
    include ::ActionView::Helpers::DateHelper
    include ::Katello::TranslationHelper
    STATUS_VALUES = {
      :stopped => _("Syncing Complete."),
      :error => _("Sync Incomplete"),
      :never_synced => _("Never Synced"),
      :running => _("Running"),
      :canceled => _("Canceled"),
      :paused => _("Paused"),
    }.with_indifferent_access

    def initialize(repo, task)
      @repo = repo
      @task = task
    end

    def sync_progress
      return {:state => nil} unless @repo
      return empty_task(@repo) unless @task
      display_output = @task.humanized[:output]
      display_output = display_output.split("\n")[0] if (display_output && @repo.version_href)
      {
        :id => @repo.id,
        :product_id => @repo.product.id,
        :progress => {:progress => @task.progress * 100},
        :sync_id => @task.id,
        :state => format_state(@task),
        :raw_state => raw_state(@task),
        :start_time => format_date(@task.started_at),
        :finish_time => format_date(@task.ended_at),
        :duration => format_duration(@task.ended_at, @task.started_at),
        :display_size => display_output,
        :size => display_output,
        :is_running => @task.pending && @task.state != 'paused',
        :error_details => @task.errors,
      }
    end

    private

    def empty_task(repo)
      state = 'never_synced'
      {
        :id => repo.id,
        :product_id => repo.product.id,
        :progress => {},
        :state => format_state(OpenStruct.new(:state => state)),
        :raw_state => state,
      }
    end

    def raw_state(task)
      return 'error' if task.result == 'error' || task.result == 'warning'
      task.state
    end

    def format_state(task)
      STATUS_VALUES[raw_state(task)] || task.state
    end

    def format_duration(finish, start)
      return if finish.nil? || start.nil?
      distance_of_time_in_words(finish, start)
    end

    def format_date(check_date)
      return if check_date.nil?
      relative_time_in_words(check_date)
    end
  end
end
