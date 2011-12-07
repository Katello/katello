class AddPlanToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :sync_plan_id, :integer, :default=>25, :null=>false
  end

  def self.down
    remove_column :products, :sync_plan_id
  end
end
