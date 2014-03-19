class DropCdnImportSuccessColumn < ActiveRecord::Migration
  def up
    remove_column :katello_products, :cdn_import_success
  end

  def down
    add_column :katello_products,  "cdn_import_success", :boolean, :default => true, :null => false
  end
end
