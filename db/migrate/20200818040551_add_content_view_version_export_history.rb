class AddContentViewVersionExportHistory < ActiveRecord::Migration[6.0]
  def change
    create_table :katello_content_view_version_export_histories do |t|
      t.timestamps
      t.string :destination_server
      t.string :path
      t.references :content_view_version, index: { name: :katello_cvv_export_history_cvv_id }
    end

    add_index :katello_content_view_version_export_histories, [:destination_server, :content_view_version_id, :path],
              unique: true, name: :katello_cvv_export_history_sat_cvv_id_path_destination
  end
end
