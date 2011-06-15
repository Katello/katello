class AddChangesetStatus < ActiveRecord::Migration
  def self.up
    add_column :changesets, :state, :string, :default=>"new", :null=>false
    remove_column :changesets, :published
  end

  def self.down
    remove_column :changesets, :state
    add_column :changesets, :published, :default=>false 
  end
end
