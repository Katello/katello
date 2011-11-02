class CreateActivationKeys < ActiveRecord::Migration
  def self.up
    create_table :activation_keys do |t|
      t.string :name
      t.string :description
      t.references :organization, :null => false
      t.references :environment, :null => false
      t.references :system_template
      t.timestamps
    end
  end

  def self.down
    drop_table :activation_keys
  end
end
