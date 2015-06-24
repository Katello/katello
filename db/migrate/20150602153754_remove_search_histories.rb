class RemoveSearchHistories < ActiveRecord::Migration
  def up
    drop_table :katello_search_histories
  end

  def down
    create_table "katello_search_histories", :force => true do |t|
      t.string   "params"
      t.string   "path"
      t.integer  "user_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "katello_search_histories", ["user_id"], :name => "index_search_histories_on_user_id"
  end
end
