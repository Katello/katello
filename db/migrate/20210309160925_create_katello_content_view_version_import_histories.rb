class CreateKatelloContentViewVersionImportHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :katello_content_view_version_import_histories do |t|
      t.string :path
      t.text :metadata
      t.references :content_view_version, index: { name: :katello_cvv_import_history_cvv_id }

      t.timestamps
    end
    add_index :katello_content_view_version_import_histories, [:content_view_version_id, :path],
              unique: true, name: :katello_cvv_import_history_sat_cvv_id_path
  end
end
