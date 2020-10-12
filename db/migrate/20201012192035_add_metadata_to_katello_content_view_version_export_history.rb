class AddMetadataToKatelloContentViewVersionExportHistory < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_content_view_version_export_histories, :metadata, :text
  end
end
