class CreateGpgs < ActiveRecord::Migration
  def self.up
    create_table :gpg_keys do |t|
      t.string :name, :null => false
      t.references :organization, :null => false
      t.text :content, :null => false
      t.timestamps
    end
    add_index(:gpg_keys, [:organization_id, :name], :unique => true)
  end

  def self.down
    remove_index :gpg_keys, [:organization_id, :name]
    drop_table :gpg_keys
  end
end
