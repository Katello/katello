class AddContentViewToDistributor < ActiveRecord::Migration
  def self.up
    add_column :distributors, :content_view_id, :integer
    add_index :distributors, :content_view_id
  end

  def self.down
    remove_index :distributors, :content_view_id
    remove_column :distributors, :content_view_id
  end
end
