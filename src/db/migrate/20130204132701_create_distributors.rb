class CreateDistributors < ActiveRecord::Migration
  def self.up
    create_table :distributors do |t|
      t.string :uuid
      t.string :name
      t.string :description
      t.string :location
      t.references :environment

      t.timestamps
    end
    add_index "distributors", ["environment_id"], :name => "index_distributors_on_environment_id"

  end

  def self.down
    drop_table :distributors
  end
end
