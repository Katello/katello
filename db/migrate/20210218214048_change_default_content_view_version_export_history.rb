class ChangeDefaultContentViewVersionExportHistory < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:katello_content_view_version_export_histories, :export_type, nil)
  end
end
