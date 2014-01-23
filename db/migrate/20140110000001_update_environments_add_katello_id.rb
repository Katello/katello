class UpdateEnvironmentsAddKatelloId < ActiveRecord::Migration
  def up
    add_column :environments, :katello_id, :string
    add_index :environments, :katello_id
  end

  def down
    remove_column :environment, :katello_id
  end
end
