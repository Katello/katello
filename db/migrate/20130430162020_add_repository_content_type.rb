class AddRepositoryContentType < ActiveRecord::Migration
  def up
    add_column :repositories, :content_type, :string, :null=>false, :default=>'yum'
  end

  def down
    remove_column :repositories, :content_type
  end
end
