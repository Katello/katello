class RemoveUserNotices < ActiveRecord::Migration
  def up
    drop_table :katello_user_notices
  end

  def down
    create_table "katello_user_notices", :force => true do |t|
      t.integer "user_id"
      t.integer "notice_id"
      t.boolean "viewed", :default => false, :null => false
    end

    add_index "katello_user_notices", ["notice_id"], :name => "index_user_notices_on_notice_id"
    add_index "katello_user_notices", ["user_id"], :name => "index_user_notices_on_user_id"
  end
end
