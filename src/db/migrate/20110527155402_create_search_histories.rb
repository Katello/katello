class CreateSearchHistories < ActiveRecord::Migration
  def self.up
    create_table :search_histories do |t|
      t.string :params
      t.string :path
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :search_histories
  end
end
