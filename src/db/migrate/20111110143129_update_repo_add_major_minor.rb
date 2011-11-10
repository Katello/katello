class UpdateRepoAddMajorMinor < ActiveRecord::Migration
  def self.up
    add_column :repositories, :major, :integer
    add_column :repositories, :minor, :string
  end

  def self.down
    remove_column :repositories, :major, :integer
    remove_column :repositories, :minor, :string
  end
end
