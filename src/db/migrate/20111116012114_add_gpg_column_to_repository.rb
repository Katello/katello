class AddGpgColumnToRepository < ActiveRecord::Migration
  def self.up
    add_column :repositories, :gpg_id, :integer
  end

  def self.down
    remove_column :repositories, :gpg_id
  end
end
