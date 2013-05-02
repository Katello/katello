class AddOrganizationToNotice < ActiveRecord::Migration
  def self.up
    change_table(:notices) { |t| t.references :organization }
    add_index :notices, :organization_id
  end

  def self.down
    change_table(:notices) { |t| t.remove :organization_id }
  end
end
