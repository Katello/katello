class CreateOrganizationUser < ActiveRecord::Migration
  def self.up
    create_table :organizations_users, :id => false do |t|
      t.belongs_to :organization, :user
    end
    add_index :organizations_users, :organization_id
    add_index :organizations_users, :user_id
  end

  def self.down
    remove_index :organizations_users, :organization_id
    remove_index :organizations_users, :user_id
    drop_table :organizations_users
  end
end
