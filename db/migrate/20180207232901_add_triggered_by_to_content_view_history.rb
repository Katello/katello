class AddTriggeredByToContentViewHistory < ActiveRecord::Migration[5.1]
  def change
    add_column :katello_content_view_histories, :triggered_by_id, :integer, :null => true
    add_foreign_key "katello_content_view_histories", "katello_content_view_versions",
                :name => "katello_cv_history_versions_triggered_by_fk", :column => "triggered_by_id"
  end
end
