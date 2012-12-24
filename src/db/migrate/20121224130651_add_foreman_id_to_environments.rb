class AddForemanIdToEnvironments < ActiveRecord::Migration
  def self.up
    change_table(:environments) {|t| t.integer :foreman_id}
    add_index :environments, [:foreman_id]
  end

  def self.down
    remove_index :environments, [:foreman_id]
    change_table(:environments) {|t| t.remove :foreman_id}
  end
end
