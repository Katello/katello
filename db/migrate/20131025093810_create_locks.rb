class CreateLocks < ActiveRecord::Migration
  def change
    create_table :katello_locks do |t|
      t.string :uuid, index: true
      t.string :name, index: true
      t.string :resource_type
      t.integer :resource_id
      t.boolean :exclusive, index: true
    end
    add_index :katello_locks, [:resource_type, :resource_id]
  end
end
