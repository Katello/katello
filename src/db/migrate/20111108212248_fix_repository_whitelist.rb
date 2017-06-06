class FixRepositoryWhitelist < ActiveRecord::Migration
  def self.up
    rename_column :repositories, :blacklisted, :enabled
    change_column_default :repositories, :enabled, true
  end

  def self.down
  end
end
