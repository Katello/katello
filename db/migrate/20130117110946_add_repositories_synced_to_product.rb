class AddRepositoriesSyncedToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :cdn_import_success, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :products, :cdn_import_success
  end
end
