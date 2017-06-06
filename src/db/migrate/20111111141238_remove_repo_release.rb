class RemoveRepoRelease < ActiveRecord::Migration
  def self.up
    remove_column :repositories, :release
  end

  def self.down
    add_column :repositories, :release, :string, :null=>true
  end
end
