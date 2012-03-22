class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username
      t.string :password
      t.boolean :helptips_enabled, :default=>true
      t.boolean :hidden, :default => false, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
