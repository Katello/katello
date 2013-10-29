class CreateDynflowTasks < ActiveRecord::Migration
  def change
    create_table :dynflow_tasks, :id => false do |t|
      t.string :uuid, index: true
      t.string :action, index: true
      t.integer :user_id, index: true
      t.integer :organization_id, index: true
    end
  end
end
