class AddChangesetsDescription < ActiveRecord::Migration
  def self.up
    add_column :changesets, :description, :string

  end

  def self.down
    remove_column :changesets, :description
  end
end
