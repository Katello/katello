class AddRepoDetails < ActiveRecord::Migration
  def self.up
    add_column :repositories, :release, :string, :null=>true
  end

  def self.down
    remove_column :repositories, :release
  end
end
