class AddPulpIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :pulp_id, :string
  end

  def self.down
    remove_column :users, :pulp_id
  end
end
