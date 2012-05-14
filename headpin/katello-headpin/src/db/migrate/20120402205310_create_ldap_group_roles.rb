class CreateLdapGroupRoles < ActiveRecord::Migration
  def self.up
    create_table :ldap_group_roles do |t|
      t.string :ldap_group
      t.belongs_to :role

      t.timestamps
    end
  end

  def self.down
    drop_table :ldap_group_roles
  end
end
