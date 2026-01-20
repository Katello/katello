class CreateKatelloContentViewAutoPublishRequest < ActiveRecord::Migration[7.0]
  def change
    create_table :katello_content_view_auto_publish_requests do |t|
      t.references :content_view, index: { unique: true, name: :katello_cv_auto_publish_request_cv_id }, null: false, foreign_key: { to_table: :katello_content_views }
      t.references :content_view_version, index: { name: :katello_cv_auto_pubish_request_cvv_id }, null: false, foreign_key: { to_table: :katello_content_view_versions }

      t.timestamps
    end
  end
end
