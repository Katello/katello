class AddingPreferencesToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :preferences, :text
  end

  def self.down
    remove_column :users, :preferences
  end
end
