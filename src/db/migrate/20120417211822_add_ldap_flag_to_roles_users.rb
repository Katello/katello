class AddLdapFlagToRolesUsers < ActiveRecord::Migration
  def self.up
    remove_column :roles, :ldap
    add_column :roles_users, :ldap, :boolean
  end

  def self.down
    add_column :roles, :ldap, :boolean
    remove_column :roles_users, :ldap
  end
end
