class AddRepoEnvironmentProductColumns < ActiveRecord::Migration

  def up
    add_column :repositories, :product_id, :int
    add_column :repositories, :environment_id, :int
    add_index :repositories, :product_id
    add_index :repositories, :environment_id
  end

  def down
    remove_column :repositories, :product_id
    remove_column :repositories, :environment_id
  end
end
