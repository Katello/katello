class CreateActivationKeys < ActiveRecord::Migration
  def self.up
    create_table :activation_keys do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :activation_keys
  end
end
