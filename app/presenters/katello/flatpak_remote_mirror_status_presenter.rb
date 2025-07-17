module Katello
  class FlatpakRemoteMirrorStatusPresenter
    include ::ActionView::Helpers::DateHelper
    include ::Katello::TranslationHelper

    def initialize(remote_repository, task)
      @remote_repository = remote_repository
      @task = task
    end

    def mirror_progress
      return { state: nil } unless @remote_repository
      return empty_task(@remote_repository) unless @task

      {
        id: @remote_repository.id,
        mirror_id: @task.id,
        state: format_state(@task),
        raw_state: raw_state(@task),
        result: @task.result,
        started_at: @task.started_at,
        last_mirror_words: time_ago_in_words(@task.started_at),
      }
    end

    private

    def empty_task(remote_repository)
      { id: remote_repository.id, progress: {}, state: "Never mirrored or task cleaned up", raw_state: "never_mirrored" }
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
