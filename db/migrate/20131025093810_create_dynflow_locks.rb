class CreateDynflowLocks < ActiveRecord::Migration
  def change
    create_table :dynflow_locks do |t|
      t.string :uuid, index: true
      t.string :resource_type, index: true
      t.integer :resource_id, index: true
    end
  end
end
