class AddChangesetDependency < ActiveRecord::Migration
  def self.up
    create_table :changeset_dependencies do |t|
       t.integer :changeset_id
       t.string :package_id
       t.string :display_name
       t.references :product, :null=>false
    end
  end

  def self.down
    drop_table :changeset_dependencies
  end
end
