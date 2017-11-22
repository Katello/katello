class LocationAddKatelloDefault < ActiveRecord::Migration[4.2]
  def up
    add_column :taxonomies, :katello_default, :boolean, :null => false, :default => false
  end

  def down
    remove_column :taxonomies, :katello_default
  end
end
