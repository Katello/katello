class AddTypeToRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :type, :string
    clause = %{
      update roles set type = 'UserOwnRole' where id in (
        select own_role_id from users where own_role_id IS NOT NULL
      )
    }
    execute(clause)
  end

  def self.down
    remove_column :roles, :type
  end
end
