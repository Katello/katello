class CreateKatelloUploadStagings < ActiveRecord::Migration[7.0]
  def change
    create_table :katello_upload_stagings do |t|
      t.references :repository, null: false, foreign_key: { to_table: :katello_repositories }
      t.string :execution_plan_uuid, null: false
      t.string :filename, null: false
      t.string :sha256, null: false
      t.text :legacy_path
      t.datetime :finished_at
      t.timestamps
    end
    add_index :katello_upload_stagings, :execution_plan_uuid
    add_index :katello_upload_stagings, [:execution_plan_uuid, :legacy_path], unique: true, name: :index_upload_stagings_on_plan_and_source
  end
end
