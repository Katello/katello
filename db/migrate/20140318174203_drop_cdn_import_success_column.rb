class DropCdnImportSuccessColumn < ActiveRecord::Migration[4.2]
  def up
    remove_column :katello_products, :cdn_import_success
  end

  def down
    add_column :katello_products, "cdn_import_success", :boolean, :default => true, :null => false
  end
end
