class CreateGpgs < ActiveRecord::Migration
  def self.up
    create_table :gpgs do |t|
      t.string :name, :null => false
      t.references :organization, :null => false
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :gpgs
  end
end
