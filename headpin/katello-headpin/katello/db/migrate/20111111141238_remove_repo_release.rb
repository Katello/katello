class RemoveRepoRelease < ActiveRecord::Migration
  def self.up
    remove_column :repositories, :release
  end

  def self.down
  end
end
