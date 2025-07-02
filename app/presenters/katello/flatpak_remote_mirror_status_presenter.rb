module Katello
  class FlatpakRemoteMirrorStatusPresenter
    include ::ActionView::Helpers::DateHelper
    include ::Katello::TranslationHelper

    def initialize(repo, task)
      @repo = repo
      @task = task
    end

    def mirror_progress
      return { state: nil } unless @repo
      return empty_task(@repo) unless @task

      {
        id: @repo.id,
        mirror_id: @task.id,
        state: format_state(@task),
        raw_state: raw_state(@task),
        result: @task.result,
        started_at: @task.started_at,
        last_mirror_words: time_ago_in_words(@task.started_at),
      }
    end

    private

    def empty_task(repo)
      { id: repo.id, progress: {}, state: "Never synced", raw_state: "never_synced" }
    end

    def raw_state(task)
      return 'error' if task.result == 'error' || task.result == 'warning'
      task.state
    end

    def format_state(task)
      task.state
    end
  end
end
