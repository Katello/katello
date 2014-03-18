class CreateContentViewHistory < ActiveRecord::Migration
  def up
    create_table 'katello_content_view_histories' do |t|
      t.references :katello_content_view_version, :null => false
      t.references :katello_environment, :null => true
      t.string :task_id, :null => true
      t.string :user, :null => false
      t.string :status, :null => false
      t.text :notes
      t.timestamps
    end

    add_index "katello_content_view_histories", ["katello_content_view_version_id"], :name => "index_cvh_cvvid"
    add_index "katello_content_view_histories", ["katello_environment_id"], :name => "index_cvh_environment_id"

    add_foreign_key "katello_content_view_histories", "katello_environments",
                        :name => "content_view_histories_cvh_environment_id", :column => "katello_environment_id"
    add_foreign_key "katello_content_view_histories", "katello_content_view_versions",
                        :name => "content_view_histories_cvh_cvv_id", :column => "katello_content_view_version_id"
  end

  def down
    drop_table 'katello_content_view_histories'
  end
end
