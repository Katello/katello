class AddContentViewVersionCounts < ActiveRecord::Migration[5.2]
  def change
    add_column :katello_content_view_versions, :content_counts, :text
    Katello::ContentViewVersion.reset_column_information
    Katello::ContentViewVersion.all.each(&:update_content_counts!)
  end
end
