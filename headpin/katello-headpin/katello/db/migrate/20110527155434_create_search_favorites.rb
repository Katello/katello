class CreateSearchFavorites < ActiveRecord::Migration
  def self.up
    create_table :search_favorites do |t|
      t.string :params
      t.string :path
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :search_favorites
  end
end
