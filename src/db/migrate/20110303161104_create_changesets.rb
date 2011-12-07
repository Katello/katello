class CreateChangesets < ActiveRecord::Migration
  def self.up
    create_table :changesets do |t|
      t.references :environment
      t.string :name
      t.boolean :published, :default=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :changesets
  end
end
