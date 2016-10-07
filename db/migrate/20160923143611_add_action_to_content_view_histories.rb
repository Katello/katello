class AddActionToContentViewHistories < ActiveRecord::Migration
  def up
    add_column :katello_content_view_histories, :action, :integer, default: 0

    Katello::ContentViewHistory.reset_column_information

    Katello::ContentViewHistory.find_each do |history|
      task_label = history.task.try(:label)
      unless task_label
        history.delete
        next
      end

      case task_label
      when "Actions::Katello::ContentViewVersion::Export"
        history.action = Katello::ContentViewHistory.actions[:export]
      when "Actions::Katello::ContentView::Publish", "Actions::Katello::ContentView::IncrementalUpdates"
        history.action = Katello::ContentViewHistory.actions[:publish]
      when "Actions::Katello::ContentView::Promote"
        history.action = Katello::ContentViewHistory.actions[:promotion]
      when "Actions::Katello::ContentView::Remove"
        history.action = Katello::ContentViewHistory.actions[:removal]
      else
        fail "Cannot determine action for task label '#{task_label}'"
      end

      history.save!
    end
  end

  def down
    remove_column :katello_content_view_histories, :action
  end
end
