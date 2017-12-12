class UpdateEnvironmentsAddKatelloId < ActiveRecord::Migration[4.2]
  def up
    add_column :environments, :katello_id, :string, :limit => 255
    add_index :environments, :katello_id
  end

  def down
    remove_column :environments, :katello_id
  end
end
