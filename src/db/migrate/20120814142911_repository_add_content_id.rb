class RepositoryAddContentId < ActiveRecord::Migration
  def self.up
    add_column :repositories, :content_id, :string, :null=>true
 
    change_column :repositories, :content_id, :string, :null=>false
    #TODO Add migration for existing repos
  end

  def self.down
    remove_column :repositories, :content_id
  end
end
