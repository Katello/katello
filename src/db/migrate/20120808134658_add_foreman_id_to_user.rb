class AddForemanIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :foreman_id, :integer
  end

  def self.down
    remove_column :users, :foreman_id
  end
end
