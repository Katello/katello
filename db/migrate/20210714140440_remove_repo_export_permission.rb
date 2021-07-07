class RemoveRepoExportPermission < ActiveRecord::Migration[6.0]
  def change
    Permission.where(:name => 'export_products').destroy_all
  end
end
