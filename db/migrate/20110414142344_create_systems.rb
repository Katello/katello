class CreateSystems < ActiveRecord::Migration
  def self.up
    create_table :systems do |t|
      t.string  :uuid
      t.string  :name
      t.string  :description
      t.string  :location
      t.references :environment
      t.timestamps
    end
  end

  def self.down
    drop_table :systems
  end
end
