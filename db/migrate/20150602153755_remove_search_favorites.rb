class RemoveSearchFavorites < ActiveRecord::Migration
  def up
    drop_table :katello_search_favorites
  end

  def down
    create_table "katello_search_favorites", :force => true do |t|
      t.string   "params"
      t.string   "path"
      t.integer  "user_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "katello_search_favorites", ["user_id"], :name => "index_search_favorites_on_user_id"
  end
end
