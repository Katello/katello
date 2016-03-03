class RemoveHelpTips < ActiveRecord::Migration
  def up
    drop_table :katello_help_tips
  end

  def down
    create_table "katello_help_tips", :force => true do |t|
      t.string   "key", :limit => 255
      t.integer  "user_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "katello_help_tips", ["user_id"], :name => "index_help_tips_on_user_id"
  end
end
