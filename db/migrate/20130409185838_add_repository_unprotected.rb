class AddRepositoryUnprotected < ActiveRecord::Migration
  def up
    add_column :repositories, :unprotected, :boolean, :default=>false, :null=>false
  end

  def down
    remove_column :repositories, :unprotected
  end
end
