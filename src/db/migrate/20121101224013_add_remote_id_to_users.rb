class AddRemoteIdToUsers < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      t.column :remote_id, :string, :bulk => true
      User.all.each do |user|
        execute "update users set remote_id = '#{user.username}' where id= #{user.id}"
      end
      t.change :remote_id, :string, :null => true
    end
    add_index(:users, :remote_id, :unique => true)
  end

  def self.down
    remove_index(:users, :column =>:remote_id)
    change_table(:users) { |t| t.remove :remote_id}
  end
end
