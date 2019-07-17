class AddMetadataProcessAfterToKatelloEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :katello_events, :metadata, :text
    add_column :katello_events, :process_after, :datetime
  end
end
