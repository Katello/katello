class CreateGpgs < ActiveRecord::Migration
  def self.up
    create_table :gpg_keys do |t|
      t.string :name, :null => false
      t.references :organization, :null => false
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :gpg_keys
  end
end
