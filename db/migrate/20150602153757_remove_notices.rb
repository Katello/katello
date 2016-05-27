class RemoveNotices < ActiveRecord::Migration
  def up
    drop_table :katello_notices
  end

  def down
    create_table "katello_notices", :force => true do |t|
      t.string   "text",            :limit => 1024, :null => false
      t.text     "details"
      t.boolean  "global", :default => false, :null => false
      t.string   "level",                                              :null => false, :limit => 255
      t.datetime "created_at",                                         :null => false
      t.datetime "updated_at",                                         :null => false
      t.string   "request_type", :limit => 255
      t.integer  "organization_id"
    end

    add_index "katello_notices", ["organization_id"], :name => "index_notices_on_organization_id"
  end
end
