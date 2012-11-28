class AddForemanIdToEnvironment < ActiveRecord::Migration
  def self.up
    add_column :environments, :foreman_id, :integer
  end

  def self.down
    remove_column :environments, :foreman_id
  end
end
