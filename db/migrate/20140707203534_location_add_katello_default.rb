class LocationAddKatelloDefault < ActiveRecord::Migration
  def up
    add_column :taxonomies, :katello_default, :boolean, :null => false, :default => true
  end

  def down
    remove_column :taxonomies, :katello_default
  end
end
