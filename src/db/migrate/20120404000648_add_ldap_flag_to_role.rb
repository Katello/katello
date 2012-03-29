class AddLdapFlagToRole < ActiveRecord::Migration
  def self.up
    add_column :roles, :ldap, :boolean
  end

  def self.down
    drop_column :roles, :ldap
  end
end
