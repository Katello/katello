class AddImportOnlyToKatelloContentView < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_content_views, :import_only, :boolean, :default => false, :null => false
  end
end
