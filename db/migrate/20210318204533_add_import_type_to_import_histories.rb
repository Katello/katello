class AddImportTypeToImportHistories < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_content_view_version_import_histories,
               :import_type, :string,
               :default => ::Katello::ContentViewVersionExportHistory::COMPLETE, :null => false
    add_index :katello_content_view_version_import_histories, :import_type, name: 'katello_cvveh_import_type'
  end
end
