class AddForemanEnvironmentIdToEnvironments < ActiveRecord::Migration
  def self.up
    add_column :environments, :foreman_id, :string # add :null => false when foreman is expected to be present
  end

  def self.down
    remove_column :environments, :foreman_id
  end
end
