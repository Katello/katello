class AddPlanToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :sync_plan_id, :integer, :null=>true
  end

  def self.down
    remove_column :products, :sync_plan_id
  end
end
