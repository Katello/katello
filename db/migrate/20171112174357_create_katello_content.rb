class CreateKatelloContent < ActiveRecord::Migration
  def change
    create_table :katello_contents do |t|
      t.string :cp_content_id, :index => true, :unique => true
      t.string :content_type, :index => true
      t.string :name, :index => true
      t.string :label, :index => true, :unique => true
      t.string :vendor
      t.string :gpg_url, :index => true
      t.string :content_url, :index => true
    end
  end
end
