class CreateContentViewVersion < ActiveRecord::Migration
  def self.up
    create_table :content_view_versions do |t|
      t.references :content_view
      t.integer  :version, :null=>false
      t.timestamps
    end
    add_index :content_view_versions, [:id, :content_view_id],
              :name => "cvv_cv_index"
  end

  def self.down
    drop_table :content_view_versions
  end
end
