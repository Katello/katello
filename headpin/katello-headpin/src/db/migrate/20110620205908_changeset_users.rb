class ChangesetUsers < ActiveRecord::Migration
  def self.up
    create_table :changeset_users do |t|
      t.integer :changeset_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :changeset_users
  end
end
