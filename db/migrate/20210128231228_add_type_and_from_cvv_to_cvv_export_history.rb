class AddTypeAndFromCvvToCvvExportHistory < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_content_view_version_export_histories,
               :export_type, :string,
               :default => ::Katello::ContentViewVersionExportHistory::COMPLETE, :null => false
    add_index :katello_content_view_version_export_histories, :export_type, name: 'katello_cvveh_export_type'

    ::Katello::ContentViewVersionExportHistory.reset_column_information
    ::Katello::ContentViewVersionExportHistory.all.each do |cvve|
      next if cvve.export_type == cvve.export_type_from_metadata
      cvve.update!(export_type: cvve.export_type_from_metadata)
    end
  end
end
