class CreateSyncPlans < ActiveRecord::Migration
  def self.up
    create_table :sync_plans do |t|
      t.string :name
      t.text :description
      t.datetime :sync_date
      t.string :interval 
      t.references :organization, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :sync_plans
  end

end
