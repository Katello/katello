class AddForeignKeysToImportExportHistories < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key "katello_content_view_version_export_histories", "katello_content_view_versions", column: "content_view_version_id", name: "content_view_version_export_histories_content_view_version_id_fk"
    add_foreign_key "katello_content_view_version_import_histories", "katello_content_view_versions", column: "content_view_version_id", name: "content_view_version_import_histories_content_view_version_id_fk"
  end
end
